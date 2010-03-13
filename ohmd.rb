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
      # Write to temp
      @changes = true
      File.open(tempname, "w") { |f|
        f.print File.read(@target)
        f.print @data
      }
      # Copy to backup
      File.copy(@target, bakname)
      # Overwrite
      File.move(tempname, @target)
    elsif block then
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
      # Compare current file and new version
      @changes = Digest::MD5.file(@target).digest != Digest::MD5.digest(@data)
      if @changes then
        # Write to temp
        File.open(tempname, "w") { |f| f.print @data }
        # Copy to backup
        File.copy(@target, bakname)
        # Overwrite
        File.move(tempname, @target)
      end
    end

    @changes
  end

  def restore
    if @changes then
      File.copy(bakname, @target)
    end
  end
end


# Exec action
class OhmExecAction < OhmAction
  def onchanges
    @options.include? "onchanges"
  end

  def do
    system(@target)
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
      elsif currentAction.is_a? OhmFileAction then
        currentAction.data << line
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
      OhmExecAction.new(action, options, target, nil)
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
def dourl(url)
  # Get URL
  # TODO
  file = "#ohm#file ohmblock: test\n"
  file << "ohm new line 1\nohm new line 2\n"
  file << "#ohm# exec onchanges :echo homo\n"

  # Parse file
  log "Applying actions from #{url}"
  fileactions, execactions = OhmParser.parseFile file

  # Apply file actions
  log "#{fileactions.count} file actions"
  changes = 0
  fileactions.each do |fa|
    changes += fa.do ? 1 : 0
  end
  log "#{changes} files modified"

  # Apply exec actions
  log "#{execactions.count} exec actions"
  execdone = 0
  error = nil
  execactions.each do |ea|
    if error.nil? && ea.onchanges != (changes==0)
      execdone += 1
      error = ea unless ea.do
    end
  end
  log "#{execdone} commands executed"

  unless error.nil?
    logerror "Error executing: #{error.target} (#{url})"

    log "Restoring modified files"
    fileactions.each do |fa|
      fa.restore
    end

    log "Executing actions on restored files"
    error = false
    execactions.each do |ea|
      if !error && ea.onchanges
        error = ea.do
      end
    end
  end

  log "Finished actions from #{url}"
end

dourl("kikoo.com")

