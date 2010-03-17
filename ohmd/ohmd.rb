#!/usr/bin/ruby

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
  def onchanges
    @options.include? "onchanges"
  end

  def rollback
    @options.include? "rollback"
  end

  def do(changes)
    unless rollback || (onchanges && !changes)
      system(@target)
    else
      true # report no error
    end
  end

  def undo
    if rollback
      system(@target)
    else
      true
    end
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

    fileactions = actions.select { |a| a.is_a? OhmFileAction }
    execactions = actions.select { |a| a.is_a? OhmExecAction }

    [fileactions, execactions]
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
def dourl(url, passphrase)
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
  file = "#ohm#file ohmblock: test\n"
  file << "ohm new olol line 1\nohm new line 2\n"
  file << "#ohm# file: test2\n"
  file << "vive les tests\n"
  file << "#ohm# exec onchanges :homo\n"
  file << "#ohm# exec rollback: echo homo\n"

  # Parse file
  log "Applying actions from #{url}"
  begin
    fileactions, execactions = OhmParser.parseFile file
  rescue Exception => e
    logerror e.message
    return
  end

  # Apply file actions
  log "#{fileactions.count} file actions"
  changes = 0
  fileactions.each do |fa|
    changes += fa.do ? 1 : 0
  end
  log "#{changes} files modified"
  changes = (changes > 0)

  # Apply exec actions
  log "#{execactions.count} exec actions"
  error = nil
  execactions.each do |ea|
    if error.nil?
      error = ea unless ea.do(changes)
    end
  end

  unless error.nil?
    logerror "Error executing: #{error.target} (#{url})"

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
end


# Get URLs to Ohm actions file from URL, parse and apply
def domasterurl(masterurl, passphrase)
  # Get URL list
  log "Downloading URLs from master: #{masterurl}"
  tempfile = "/tmp/ohm-urls"
  wgot = system("wget -q -t 5 --post-data 'pp=#{passphrase}' #{masterurl} -O #{tempfile}")
  unless wgot
    logerror "Could not retreive URLs from #{masterurl}"
    return
  end
  file = File.read(tempfile)
  File.delete(tempfile)

  file = "perdu.com\n"

  # Do all URLs
  file.each_line do |url|
    dourl(url.chomp, passphrase)
  end
end


domasterurl("perdu.com", "olol")

