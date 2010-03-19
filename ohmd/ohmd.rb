#!/usr/bin/ruby

require "yaml"
require "ftools"
require 'digest/md5'


# Action
class OhmAction
  attr_reader :action, :options, :target, :data
  attr_writer :data

  def initialize(action, options, target, data)
    @action = action
    @options = (options.is_a? Array) ? options : (OhmParser.parseOptions options)
    @target = target
    @data = data
  end

  def do
    raise NotImplementedError, "'do' must be overridden"
  end

  def undo
    raise NotImplementedError, "'undo' must be overridden"
  end
end


# File action
class OhmFileAction < OhmAction
  attr_reader :changes

  def initialize(action, options, target, data)
    super
    @changes = false
  end

  def tempname
    "/tmp/ohm-" + Digest::MD5.hexdigest(@target) + ".tmp"
  end

  def bakname
    @target + ".ohm-backup"
  end

  def append
    @options.include? "append"
  end

  def block
    @options.include? "ohmblock"
  end

  def do
    if append then
      @changes = true
      @newfile = false
      # Write to temp
      File.open(tempname, "w") { |f|
        f.print File.read(@target)
        f.print @data
      }
      # Copy to backup
      File.copy(@target, bakname)
      # Overwrite
      File.move(tempname, @target)
    elsif block then
      @newfile = false

      blockstart = "\n### OHM GENERATED CONFIG ### DO NOT REMOVE THIS LINE ###\n"
      blockend   = "### END OF OHM CONFIG ### DO NOT REMOVE THIS LINE ###\n"
      currentblock = File.read(@target).slice(/#{blockstart}.*#{blockend}/m)
      newblock = blockstart + @data + blockend

      # Compare current and new version
      @changes = currentblock.nil? || currentblock != newblock
      if @changes then
        # Write to temp
        currentfile = currentblock.nil? ? [File.read(@target)] : File.read(@target).split(currentblock)
        File.open(tempname, "w") { |f|
          f.print currentfile[0]
          f.print newblock
          f.print currentfile[1] unless currentfile[1].nil?
        }
        # Copy to backup
        File.copy(@target, bakname)
        # Overwrite
        File.move(tempname, @target)
      end
    else
      @newfile = !File.exists?(@target)
      # Compare current file and new version
      @changes = @newfile || Digest::MD5.file(@target).digest != Digest::MD5.digest(@data)
      if @changes then
        # Write to temp
        File.open(tempname, "w") { |f| f.print @data }
        # Copy to backup
        File.copy(@target, bakname) unless @newfile
        # Overwrite
        File.move(tempname, @target)
      end
    end

    @changes
  end

  def undo
    if @newfile then
      File.delete(@target)
    elsif @changes then
      File.copy(bakname, @target)
      File.delete(bakname)
    end
  end
end


# Exec action
class OhmExecAction < OhmAction
  attr_reader :docommand, :undocommand, :done

  def initialize(action, options, target, data)
    super
    @done = false
  end

  def onchanges
    @options.include? "onchanges"
  end

  def onchangesto
    @options.include? "onchangesto"
  end

  def do(changedfiles)
    splitdata = @data.split("\n###\n")
    if splitdata.count > 2
      raise RuntimeError, "Invalid 'exec' action data:\n#{data}"
    elsif splitdata.count == 2
      @docommand = splitdata[0]
      @undocommand = splitdata[1]
    else
      @docommand = @data
    end

    @done = (onchanges && changedfiles.count > 0) ||
            (onchangesto && changedfiles.select {|cf| cf.target==@target && cf.changes}.count > 0) ||
            (!onchanges && !onchangesto)
    if @done
      system(@docommand)
    else
      true # report no error
    end
  end

  def undo
    if @done && @undocommand
      system(@undocommand)
    else
      true
    end
  end
end


# URL action
class OhmURLAction < OhmAction
  def do
    raise NotImplementedError, "'do' is not implemented for 'url' action"
  end

  def undo
    raise NotImplementedError, "'undo' is not implemented for 'url' action"
  end
end


# Parser
class OhmParser
  def self.parseFile(file)
    actions = []
    currentAction = nil

    file.each_line { |line|
      if isOhmLine line then
        actions << currentAction unless currentAction.nil?
        currentAction = parseLine line
      else
        begin
          currentAction.data << line
        rescue
          raise RuntimeError, "Invalid file (doesn't start with an action)"
        end
      end
    }
    actions << currentAction unless currentAction.nil?

    actions
  end

  def self.isOhmLine(line)
    line.start_with?("#ohm#")
  end

  def self.parseLine(line)
    unless isOhmLine line then
      raise RuntimeError, "Trying to parse an invalid line"
    end

    action = line.slice /\A#ohm#\s*([^\s:]+)(\s|:)/, 1
    options = line.slice /#{action}([^:]*):/, 1
    target = line.slice /:([^:]*)\Z/, 1
    target.strip!

    case action
    when "file"
      OhmFileAction.new(action, options, target, "")
    when "exec"
      OhmExecAction.new(action, options, target, "")
    when "url"
      OhmURLAction.new(action, options, target, "")
    else raise RuntimeError, "Unknown action: #{action}"
    end
  end

  def self.parseOptions(options)
    options.squeeze!(" ")
    options.strip!
    options.split(" ")
  end
end


# Log given message
def log(message)
  puts "> " + message
end

# Log given error message
def logerror(message)
  puts "! " + message
end


# Get Ohm actions file from URL, parse and apply
def dourl(url, passphrase, options = {})
  options[:done] ||= []
  if options[:done].include? url
    log "Already did actions from #{url}, skipping"
    return
  end

  # Get action file
  log "Downloading actions from URL: #{url}"
  tempfile = "/tmp/ohm-actions"
  wgot = system("wget -q -t 5 --post-data 'pp=#{passphrase}' #{url} -O #{tempfile}")
  unless wgot
    logerror "Could not retreive actions from #{url}"
    return
  end
  file = File.read(tempfile)
  File.delete(tempfile)

  # TESTING
#  file = "#ohm# file ohmblock: test\n"
#  file << "ohm line 1\nohm line 2\n"
#  file << "#ohm# file append: test2\n"
#  file << "vive les tests\n"
#  file << "#ohm# exec onchangesto: test2\necho homo\n###\necho bedo\n"
#  file << "#ohm# exec onchanges:\nkikoo\n"

  # Parse file
  log "Applying actions from #{url}"
  begin
    actions = OhmParser.parseFile file
  rescue Exception => e
    logerror e.message
    return
  end

  # Apply file actions
  fileactions = actions.select { |a| a.is_a? OhmFileAction }
  log "#{fileactions.count} file actions"
  changes = 0
  fileactions.each do |fa|
    changes += fa.do ? 1 : 0
  end
  log "#{changes} files modified"
  changedfiles = fileactions.select { |fa| fa.changes }

  # Apply exec actions
  execactions = actions.select { |a| a.is_a? OhmExecAction }
  log "#{execactions.count} exec actions"
  error = nil
  execactions.each do |ea|
    if error.nil?
      error = ea unless ea.do(changedfiles)
    end
  end

  unless error.nil?
    logerror "Error executing: #{error.docommand} (#{url})"

    log "Restoring modified files"
    fileactions.each do |fa|
      fa.undo
    end

    log "Executing rollback actions"
    execactions.each do |ea|
      ea.undo
    end
  end

  log "Finished actions from #{url}"
  options[:done] << url

  # Parse new URLs
  urlactions = actions.select { |a| a.is_a? OhmURLAction }
  urlactions.each do |ua|
    dourl(ua.target, passphrase, :done => options[:done])
  end
end


# Parse config and run with master url
def run
  cfg = YAML.load_file("ohmd.conf")
  masterurl = cfg["panel_url"] + "/ohmd"
  dourl(masterurl, cfg["passphrase"])
#  dourl("perdu.com", cfg["passphrase"])
end

run

