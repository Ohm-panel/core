# Ohm - Open Hosting Manager
# Installer

require 'yaml'
require 'ftools'


LOG = "ohm-install.log"
STEPS = 6

# Load distribution configuration
@args = ARGV
cfg = YAML.load_file("install/#{@args.last}.yml")


# Class to print progress
class Dialog
  def dialog(action, text, options="")
    "dialog --title \"Ohm - Open Hosting Manager\" --#{action} \"\n#{text}\n\n\" 0 0 #{options}"
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

  def exit
    system "dialog --clear
            clear"
  end
end

def exec(cmd)
  system("(#{cmd}) >> #{LOG}")
end

# Welcome
dialog = Dialog.new
go = dialog.yesno("Welcome to the Ohm installer for #{cfg["distro"]}.\n
Please verify this is your distribution and you are connected to the internet.
Proceed?")
exit 1 unless go

# Phusion Passenger (mod_rails)
dialog.progress(0, "Preparing Phusion Passenger (mod_rail)")
exec(cfg["mod_rails"])

# Update and install packages
dialog.progress(1, "Installing required packages")
system cfg["packages"] # We don't use exec because input might be needed

# Configure mount points for quota
dialog.progress(2, "Configuring the quota manager")
fstab = File.read("/etc/fstab")
newfstab = ""
fstab.each_line do |line|
  if line.strip.start_with?("#") || line == "\n"
    newfstab << line
  else
    fields = line.squeeze(" ").split(" ")
    if fields[1].start_with?("/") && fields[0] != "proc"
      fields[3] += ",usrquota,grpquota"
      newfstab << fields.join("   ") + "\n"
    else
      newfstab << line
    end
  end
end
File.open("/etc/fstab", "w") { |f| f.print newfstab }

# Install requires Gems
dialog.progress(3, "Installing required gems")
exec(cfg["gems"])

# Configure Apache
dialog.progress(4, "Configuring Apache")                                        ### LIGNE RailsEnv A ENLEVER APRES TESTS !!!
vhost = "<VirtualHost *:80>
  RailsEnv development
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
exec("a2ensite ohm")
exec("a2dissite default")

# Copy files
dialog.progress(5, "Copying Ohm files")
File.makedirs cfg["panel_path"]
exec("cp -rp webapp/* #{cfg["panel_path"]}/")
File.makedirs cfg["ohmd_path"]
exec("cp -rp ohmd/* #{cfg["ohmd_path"]}/
      chmod u+x #{cfg["ohmd_path"]}/ohmd.rb")

# Finished, reboot
dialog.progress(STEPS, "Finished")
dialog.message("Installation is complete. Your computer will now reboot.")
dialog.exit
system(cfg["reboot"])

