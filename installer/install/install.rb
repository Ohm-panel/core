# Ohm - Open Hosting Manager
# Installer

require 'yaml'
LOG = "ohm-install.log"
STEPS = 4

# Load distribution configuration
@args = ARGV
cfg = YAML.load_file("install/#{@args.last}.yml")


# Class to print progress
class Dialog
  def dialog(action, text, options="")
    "dialog --title \"Ohm - Open Hosting Manager\" --#{action} \"\n#{text}\n\n\" 0 0 #{options}"
  end

  def progress(pc, text=nil)
    @text = text if text
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
dialog.progress((1/STEPS).to_i, "Installing required packages")
exec(cfg["packages"])


# Install requires Gems
dialog.progress((2/STEPS).to_i, "Installing required gems")
exec(cfg["gems"])


# Configure Apache
dialog.progress((3/STEPS).to_i, "Configuring Apache")
vhost = "<VirtualHost *:80>
  RailsEnv development                                                          ### LIGNE A ENLEVER APRES TESTS !!!
  DocumentRoot $PANEL_PATH/public
  <Directory $PANEL_PATH/public>
    Allow from all
    Options FollowSymLinks -MultiViews
  </Directory>
</VirtualHost>"
File.open("#{cfg["apache_sites"]}/ohm", "w") { |f| f.print vhost }
File.open(cfg["apache_conf"], "w") { |f|
  f.print File.read(cfg["apache_conf"])
  f.print "ServerName 0.0.0.0\n"
  f.print "NameVirtualHost *:80\n"
}
exec("a2ensite ohm")
exec("a2dissite default")
exec(cfg["apache_restart"])

dialog.progress((4/STEPS).to_i, "Configuring Apache")
dialog.exit

