#!/usr/bin/ruby

require 'yaml'
require 'ftools'
require 'digest/md5'
require 'net/http'
require 'uri'


# Action
class OhmAction
  attr_reader :action, :options, :target, :data, :report_value
  attr_writer :data

  def initialize(action, options, target, report_value, data)
    @action = action
    @options = (options.is_a? Array) ? options : (OhmParser.parseOptions options)
    @target = target
    @report_value = report_value
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

  def initialize(action, options, target, report_value, data)
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
      @newfile = !File.exists?(@target)

      # Create dummy file if new
      if @newfile
        File.open(@target, "w") { |f| f.print "" }
      end

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
      @newfile = !File.exists?(@target)

      # Create dummy file if new
      if @newfile
        File.open(@target, "w") { |f| f.print "" }
      end

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

  def initialize(action, options, target, report_value, data)
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
    report_value = line.slice /\s+(\d+)\Z/, 1
    target = line.slice /#{options}:(.*)\s*#{report_value}/, 1
    target.strip!

    case action
    when "badlogin"
      raise RuntimeError, "Passphrase rejected by panel"
    when "file"
      OhmFileAction.new(action, options, target, report_value, "")
    when "exec"
      OhmExecAction.new(action, options, target, report_value, "")
    when "url"
      OhmURLAction.new(action, options, target, report_value, "")
    else raise RuntimeError, "Unknown action: #{action}"
    end
  end

  def self.parseOptions(options)
    options.squeeze!(" ")
    options.strip!
    options.split(" ")
  end
end


# Get current time for display (for logging functions)
def timestamp
  "[" + Time.new.strftime("%Y-%m-%d %H:%M:%S") + "]"
end

# Log given message
def log(message)
  puts "#{timestamp} #{message}"
end

# Log given error message
def logerror(message)
  puts "#{timestamp}   !!!   #{message}   !!!"
end


# This class must be used for communication with the panel
class OhmPanelConnection
  def initialize(panel_url, passphrase, os)
    @panel_url = panel_url
    @passphrase = passphrase
    @os = os
  end

  def url(ctrlurl)
    URI.parse("#{@panel_url}/#{ctrlurl}")
  end

  def get(ctrlurl, options = {})
    options[:passphrase] = @passphrase
    options[:os] = @os
    res = Net::HTTP.post_form(url(ctrlurl), options)
    res.body.chomp
  end

  def getactions(ctrlurl)
    get(ctrlurl)
  end

  def report(ctrlurl, success, report_values = [])
    get(ctrlurl, :done => true, :success => success, :report_values => report_values)
  end
end


# Get Ohm actions file from URL, parse and apply
def dourl(connection, options = {})
  options[:ctrlurl] ||= "ohmd"
  options[:done] ||= []
  url = connection.url(options[:ctrlurl])

  if options[:done].include? url
    log "Already did actions from #{url}, skipping"
    return
  end

  # Get action file
  log "Downloading actions from URL: #{url}"
  begin
    file = connection.getactions(options[:ctrlurl])
  rescue Exception => e
    logerror "Could not retreive actions from #{url}: #{e.message}"
    return
  end

  # Parse file
  log "Applying actions from #{url}"
  begin
    actions = OhmParser.parseFile file
  rescue Exception => e
    logerror "#{e.message} (from #{url})"
    return
  end

  # Apply file actions
  fileactions = actions.select { |a| a.is_a? OhmFileAction }
  log "#{fileactions.count} file actions"
  fileactions.each do |fa|
    fa.do
  end
  changedfiles = fileactions.select { |fa| fa.changes }
  log "#{changedfiles.count} files modified"

  # Apply exec actions
  execactions = actions.select { |a| a.is_a? OhmExecAction }
  log "#{execactions.count} exec actions"
  error = nil
  execactions.each do |ea|
    if error.nil?
      error = ea unless ea.do(changedfiles)
    end
  end

  # Success or error
  if error.nil?
    # Success, report with values
    report_values = actions.collect { |a| a.report_value }.compact
    connection.report(options[:ctrlurl], true, report_values)
  else
    # Error, rollback and report
    logerror "Error executing: #{error.docommand} (#{url})"

    log "Restoring modified files"
    fileactions.each do |fa|
      fa.undo
    end

    log "Executing rollback actions"
    execactions.each do |ea|
      ea.undo
    end

    connection.report(options[:ctrlurl], false)
  end

  # Report end

  log "Finished actions from #{url}"
  options[:done] << url

  # Parse new URLs
  urlactions = actions.select { |a| a.is_a? OhmURLAction }
  urlactions.each do |ua|
    dourl(connection, :ctrlurl => ua.target, :done => options[:done])
  end
end


# Parse config and run with master url
def run
  cfg = YAML.load_file("ohmd.conf")
  conn = OhmPanelConnection.new(cfg["panel_url"], cfg["passphrase"], cfg["os"])
  dourl(conn)
end

run

