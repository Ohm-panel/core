# Ohm - Open Hosting Manager
# Installer

require 'yaml'
require 'ftools'


LOG = "install.log"
STEPS = 8

# Load distribution configuration
args = ARGV
distro = args.last
cfg = YAML.load_file("install/#{distro}.yml")


# Class to print progress
class Dialog
  def dialog(action, text, params="", options="")
    "dialog --title \"Ohm - Open Hosting Manager\" #{options} --#{action} \"\n#{text}\n\n\" 0 0 #{params}"
  end

  def progress(step, text=nil)
    @text = text if text
    pc = (step*100/STEPS).to_i
    system("#{dialog "gauge", @text, pc} &")
    sleep 1
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
  system "(#{cmd}) >> #{LOG}"
end

# Welcome
dialog = Dialog.new
go = dialog.yesno("Welcome to the Ohm installer for #{cfg["distro"]}.\n
Please verify this is your distribution and you are connected to the internet.
Proceed?")
exit 1 unless go

# Phusion Passenger (mod_rails)
dialog.progress(0, "Preparing Phusion Passenger (mod_rail)")
exec cfg["mod_rails"]

# Update and install packages
dialog.progress(1, "Installing required packages")
exec cfg["packages_update"]
system cfg["packages"] # We don't use exec because input might be needed

# Configure mount points for quota
dialog.progress(2, "Configuring packages")
fstab = File.read("/etc/fstab")
newfstab = ""
fstab.each_line do |line|
  if line.strip.start_with?("#") || line == "\n"
    newfstab << line
  else
    fields = line.squeeze(" ").split(" ")
    if fields[1].start_with?("/") && fields[0] != "proc"
      fields[3] += ",usrquota,grpquota"                                         ### Ajouter acl si il faut..
      newfstab << fields.join("   ") + "\n"
    else
      newfstab << line
    end
  end
end
File.open("/etc/fstab", "w") { |f| f.print newfstab }

# Install requires Gems
dialog.progress(3, "Installing required gems")
exec cfg["gems"]

# Configure Apache
dialog.progress(4, "Configuring Apache")                                        ### LIGNE "RailsEnv development" A ENLEVER APRES TESTS !!!
vhost = "<VirtualHost *:80>
  DocumentRoot #{cfg["panel_path"]}/public
  <Directory #{cfg["panel_path"]}/public>
    Allow from all
    Options FollowSymLinks -MultiViews
  </Directory>
</VirtualHost>"
File.open("#{cfg["apache_sites"]}/ohm", "w") { |f| f.print vhost }
apacheconf = File.read(cfg["apache_conf"])
File.open(cfg["apache_conf"], "w") { |f|
  f.print apacheconf
  f.print "\nServerName 0.0.0.0\n"
  f.print "NameVirtualHost *:80\n"
}
exec "a2ensite ohm"
exec "a2dissite default"

# Copy files
dialog.progress(5, "Copying Ohm files")
File.makedirs cfg["panel_path"]
exec "cp -rp webapp/* #{cfg["panel_path"]}/"
File.makedirs cfg["ohmd_path"]
exec "cp -rp ohmd/* #{cfg["ohmd_path"]}/
      chmod u+x #{cfg["ohmd_path"]}/ohmd.rb"

# Generate Ohmd config
dialog.progress(6, "Generating Ohmd configuration")
File.open("#{cfg["ohmd_path"]}/ohmd.yml", "w") { |f|
  f.print "panel_path: #{cfg["panel_path"]}\n"
  f.print "os: #{distro}\n"
}


# Generate panel config
# Create db and user
dbpwd = dialog.passwordbox "Please enter the master password for mysql (root@localhost)"
dialog.progress(7, "Configuring the Ohm panel")
PWD_CHARS = [('a'..'z'),('A'..'Z'),(0..9)].inject([]) {|s,r| s+Array(r)}
dbohmpwd = Array.new(16) { PWD_CHARS[ rand(PWD_CHARS.size) ] }
mysql_cmds = "CREATE USER 'ohm'@'localhost' IDENTIFIED BY '#{dbohmpwd}'; "
mysql_cmds += "CREATE DATABASE ohm; "
mysql_cmds += "GRANT ALL PRIVILEGES ON ohm.* TO 'ohm'@'localhost'; "
exec "mysql -u root -p#{dbpwd} -e \"#{mysql_cmds}\""

# Put details in rails and migrate
dbyml = "production:
           adapter: mysql
           host: localhost
           database: ohm
           username: ohm
           password: #{dbohmpwd}"
File.open("#{cfg["panel_path"]}/config/database.yml", "w") { |f| f.print dbyml }
exec "cd #{cfg["panel_path"]}; rake db:migrate RAILS_ENV=production"

# Add admin user
users_on_system = File.read("/etc/passwd").split("\n").
                  select { |u| u.split(":")[2].to_i >= 1000 && u.split(":")[0] != "nobody" }.
                  collect { |u| u.split(":")[0] }
admin_username = dialog.select("Select user to use as administrator:", users_on_system)
admin_password = dialog.passwordbox "Enter password for #{admin_username}"
admin_email = dialog.inputbox "Enter e-mail address for #{admin_username}"
require 'rubygems'
require 'active_record'
ActiveRecord::Base.establish_connection(YAML.load(dbyml)["production"])
require "#{cfg["panel_path"]}/app/models/user"
admin = User.new(:username => admin_username,
                 :email => admin_email,
                 :password => admin_password,
                 :password_confirmation => admin_password)
admin.save

# Finished, reboot
dialog.progress(STEPS, "Finished")
rb = dialog.yesno("Installation is complete, but you MUST reboot before using Ohm.\n\nReboot now?")
dialog.exit
system cfg["reboot"] if rb

