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
# Default modules
modules = [ Service.new(:controller=>"users", :name=>"Users", :daemon_installed=>true, :deleted=>false),
            Service.new(:controller=>"apache2", :name=>"Apache", :daemon_installed=>true, :deleted=>false),
            Service.new(:controller=>"bind9", :name=>"Bind DNS", :daemon_installed=>true, :deleted=>false) ]
modules.concat Service.all
modtoexec = []
modules.each do |mod|
  begin
    # Try to load OS-specific module first
    require "#{mod.controller}/#{os}"
    modtoexec << mod
  rescue MissingSourceFile
    begin
      # Try to load default module
      require "#{mod.controller}/default"
      modtoexec << mod
    rescue MissingSourceFile
      # Ignore modules with no daemon
      log " - No daemon found for #{mod.name}"
    end
  end
end

# Exec modules
modtoexec.each do |mod|
  if mod.deleted
    log "Removing module: #{mod.name}"
    unless !mod.daemon_installed || Object.const_get("Ohmd_#{mod.controller}").remove
      logerror "Error removing module: #{mod.name}"
      next
    end
    mod.destroy
  else
    log "Executing #{mod.name}"
    Object.const_get("Ohmd_#{mod.controller}").exec
  end
end


rescue Exception => e
  logerror e
end

