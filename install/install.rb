### Ohm - Open Hosting Manager <http://joelcogen.com/projects/ohm/> ###
#
# Installer
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

require 'yaml'
require 'ftools'


LOG = "install.log"
STEPS = 8

# Load distribution configuration
args = ARGV
distro = args.last
cfg = YAML.load_file("install/#{distro}.yml")

# Modify config if dev mode
dev = args.include? "--dev"
if dev
  cfg["panel_path"] = "#{Dir.pwd}/webapp"
  cfg["ohmd_path"] = "#{Dir.pwd}/ohmd"
end


# Class to print progress
class Dialog
  def dialog(action, text, params="", options="")
    "dialog --title \"Ohm - Open Hosting Manager\" #{options} --#{action} \"\n#{text}\n\n\" 0 0 #{params}"
  end

  def progress(step, text=nil)
    @text = text if text
    pc = (step*100/STEPS).to_i
    system("#{dialog "gauge", @text, pc} &")
  end

  def message(text)
    system(dialog "msgbox", text)
  end

  def yesno(text)
    system(dialog "yesno", text)
  end

  def inputbox(text)
    `#{dialog "inputbox", text, "--stdout"}`
  end

  def passwordbox(text)
    `#{dialog "passwordbox", text, "--stdout", "--insecure"}`
  end

  def select(text, options)
    items = options.collect { |o| "#{o} \"\"" }.join(" ")
    `#{dialog "menu", text, "0 "+items, "--stdout --no-cancel"}`
  end

  def exit
    system "dialog --clear
            clear"
  end
end

def exec(cmd)
  system "(#{cmd}) >> #{LOG} 2>&1" or raise RuntimeError.new("Error during installation. Please see #{LOG} for details")
end


# Welcome
File.open(LOG, "w") { |f| f.puts "Install starting (#{Time.new})" }
dialog = Dialog.new
go = dialog.yesno("Welcome to the Ohm installer for #{cfg["distro"]}.#{dev ? " (DEV MODE)" : ""}\n
Please verify this is your distribution and you are connected to the internet.
Proceed?")
exit 1 unless go


# Check internet connection
dialog.progress(0, "Checking internet connection...")
unless system "ping -c 2 google.com >> /dev/null"
  dialog.exit
  puts "No internet connection. Aborting"
  exit 1
end


# Phusion Passenger (mod_rails)
dialog.progress(0, "Preparing Phusion Passenger (mod_rail)")
exec cfg["mod_rails"]


# Update and install packages
dialog.progress(1, "Installing required packages")
exec cfg["packages_update"]
system cfg["packages"] # We don't use exec because input might be needed


# Configure mount points for quota and ACL
dialog.progress(2, "Configuring packages")
toremount = []
fstab = File.read("/etc/fstab")
newfstab = ""
fstab.each_line do |line|
  if line.strip.start_with?("#") || line == "\n"
    newfstab << line
  else
    fields = line.squeeze(" ").split(" ")
    if fields[1].start_with?("/") && fields[0] != "proc"
      fields[3] += ",usrquota,grpquota,acl"
      newfstab << fields.join("   ") + "\n"
      toremount << fields[1]
    else
      newfstab << line
    end
  end
end
File.open("/etc/fstab", "w") { |f| f.print newfstab }

# Remount modified mountpoints
toremount.each do |mp|
  system "mount -o remount #{mp}"
end


# Install requires Gems
dialog.progress(3, "Installing required gems")
exec "gem install bundler"
dialog.progress(3.2)
exec "cd webapp; bundle install --without development"


# Configure Apache
dialog.progress(4, "Configuring Apache")
vhost = "<VirtualHost *:80>
  DocumentRoot #{cfg["panel_path"]}/public
  <Directory #{cfg["panel_path"]}/public>
    Allow from all
    Options FollowSymLinks -MultiViews
  </Directory>
</VirtualHost>"
File.open("#{cfg["apache_sites"]}/ohm", "w") { |f| f.print vhost }
File.open(cfg["apache_conf"], "a") { |f|
  f.puts "\nServerName 0.0.0.0"
  f.puts "NameVirtualHost *:80"
}
exec "a2ensite ohm"
exec "a2dissite default"
exec "a2enmod rewrite"
exec cfg["apache_restart"]

# Configure PHP
File.open(cfg["php_ohm_ini"], "w") { |f|
  f.puts "display_errors = Off"
}

# Configure BIND
dialog.progress(4.5, "Configuring BIND")
named = File.read("/etc/bind/named.conf.options")
newnamed = ""
named.each_line do |line|
  if line.strip.start_with?("listen-on")
    newnamed << "listen-on { any; }\n";
  elsif line.strip.start_with?("listen-on-v6")
    newnamed << "listen-on-v6 { any; }\n";
  else
    newnamed << line
  end
end
File.open("/etc/bind/named.conf.options", "w") { |f| f.print newnamed }


# Copy files
unless dev
  dialog.progress(5, "Copying Ohm files")
  File.makedirs cfg["panel_path"]
  exec "cp -rp webapp/* #{cfg["panel_path"]}/"
  File.makedirs cfg["ohmd_path"]
  exec "cp -rp ohmd/* #{cfg["ohmd_path"]}/
        chmod u+x #{cfg["ohmd_path"]}/ohmd.rb"
else
  dialog.progress(5, "Copying Ohm files - SKIPPED FOR DEV MODE")
end


# Generate Ohmd config
unless dev
  dialog.progress(6, "Generating Ohmd configuration")
  File.open("#{cfg["ohmd_path"]}/ohmd.yml", "w") { |f|
    f.puts "panel_path: #{cfg["panel_path"]}"
    f.puts "os: #{distro}"
  }
end

# Create install-modules script
File.open("/usr/bin/ohm-install-modules", "w") { |f|
  f.puts "#!/bin/sh"
  f.puts "cd #{cfg["ohmd_path"]}"
  f.puts "./ohm-install-modules.rb"
}
exec "chmod u+rwx,go-wx /usr/bin/ohm-install-modules"


# Database

# Select
if dev
  dbtype = "sqlite3"
else
  dbtype = dialog.select "Please select the database you wish to use", cfg["databases"]
end


# Install packages
system cfg["#{dbtype}_packages"]

# Load installer and go
dialog.progress(7, "Setting up the database")
require "install/#{dbtype}"
setup_database cfg, dialog unless dev
exec "cd #{cfg["panel_path"]}; rake db:setup RAILS_ENV=production"
exec "cd #{cfg["panel_path"]}; rake ohm:setup RAILS_ENV=production"


# Set permissions
if dev
  system "chmod -R a+rw *"
  system cfg["apache_restart"]
else
  system "chown -R www-data:www-data #{cfg["panel_path"]}"
  system "chown -R root:root #{cfg["ohmd_path"]}"
  system "chmod -R go-wx #{cfg["panel_path"]}"
  system "chmod -R go-wx #{cfg["ohmd_path"]}"
end


# Add CRON job for daemon
unless dev
  File.open(cfg["crontab"], "a") { |f|
    f.puts "\n# OHM DAEMON"
    f.puts "# Removing this line will prevent Ohm from working correctly"
    f.puts "# Do not edit this line unless you know exactly what you're doing"
    f.puts "*/5 * * * * root (cd #{cfg["ohmd_path"]} && ruby ohmd.rb >> /var/log/ohmd.log 2>&1)"
  }
end


# Finished
dialog.progress(STEPS, "Finished")
dialog.message("Installation complete!")
dialog.exit

