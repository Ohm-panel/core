#!/usr/bin/ruby

require 'rubygems'
require 'active_record'
require 'yaml'

# Load Ohmd config
cfg = YAML.load_file("ohmd.yml")
os = cfg["os"]
panel_path = cfg["panel_path"]

# Logging
def timestamp
  Time.new.strftime("%Y-%m-%d %H:%M:%S")
end
def log(message)
  puts "#{timestamp} | #{message}"
end
def logerror(message)
  puts "#{timestamp} !!! #{message}"
end

log "Ohmd start"
begin

# Load DB config from panel
log "Loading configuration from panel"
dbcfg = YAML.load_file("#{panel_path}/config/database.yml")["production"]
dbcfg["database"] = "#{panel_path}/#{dbcfg["database"]}" if dbcfg["adapter"]=="sqlite3"
log "Connecting to database"
ActiveRecord::Base.establish_connection(dbcfg)

# Include all models from panel
log "Loading models"
Dir.new("#{panel_path}/app/models").each do |model|
  model_path = "#{panel_path}/app/models/#{model}"
  require "#{model_path}" if File.file?(model_path)
end

# Load modules
log "Loading modules"
modules = ["users", "apache2"] # Default modules
modules.concat Service.all.collect { |s| s.controller }
modtoexec = []
modules.each do |mod|
  begin
    # Try to load OS-specific module first
    require "#{mod}/#{os}"
    modtoexec << mod
  rescue MissingSourceFile
    begin
      # Try to load default module
      require "#{mod}/default"
      modtoexec << mod
    rescue MissingSourceFile
      # Ignore modules with no daemon
      log " - No daemon found for #{mod}"
    end
  end
end

# Exec modules
modtoexec.each do |m|
  log "Executing #{m}"
  Object.const_get("Ohmd_#{m}").exec
end


rescue Exception => e
  logerror e
end

