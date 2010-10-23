#!/usr/bin/ruby
#
### Ohm - Open Hosting Manager <http://joelcogen.com/projects/ohm/> ###
#
# Modules installer
#
# Copyright (C) 2009-2010 UMONS <http://www.umons.ac.be>
# Copyright (C) 2010 Joel Cogen <http://joelcogen.com>
#
# This file is part of Ohm.
#
# Ohm is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ohm is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with Ohm. If not, see <http://www.gnu.org/licenses/>.

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

log "Ohm Module Installer start"
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

# Look for modules to be installed
modstoinst = Service.all.select { |s| ! s.daemon_installed && s.install_files }
modstoinst.each do |mod|
  log "Copying new module: #{mod.name}"
  unless system "cp -rp #{panel_path}/#{mod.install_files}/ohmd/* ./"
    logerror "Error during copy"
    next
  end
  system "rm -rf #{mod.install_files}"
  system "chown -R root:root ./"
  system "chmod -R go-rwx ./"
  mod.install_files = nil
  mod.save
end

# Load modules
log "Loading modules"
# Default modules
modules = Service.all
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
  unless mod.daemon_installed || mod.deleted
    log "Installing new module: #{mod.name}"
    unless Object.const_get("Ohmd_#{mod.controller}").install
      logerror "Error installing module: #{mod.name}"
      next
    end
    mod.daemon_installed = true
    mod.save
  end
end

system "service apache2 force-reload" # Required for the new routes in Rails to work

rescue Exception => e
  logerror e
end

