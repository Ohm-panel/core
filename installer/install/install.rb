# Ohm - Open Hosting Manager
# Installer

require 'yaml'

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

  def tailbox(file)
    system "echo \"\" >> /tmp/ohmtail"
    system "dialog --title \"Installing required gems\" --no-kill --tailbox #{file} 0 0"
  end

  def exit
    system "dialog --clear
            clear"
  end
end


# Welcome
dialog = Dialog.new
go = dialog.yesno("Welcome to the Ohm installer for #{cfg["distro"]}.\n\nProceed?")
exit 1 unless go

# Brightbox repo for Phusion Passenger (mod_rails)
dialog.progress(0, "Adding repository for Passenger Phusion (mod_rail)")
File.open("/etc/apt/sources.list.d/brightbox.list", "w") { |f|
  f.print File.read("/etc/apt/sources.list.d/brightbox.list")
  f.print "deb http://apt.brightbox.net hardy main\n"
}
dialog.progress(50)
system("wget -q -O - http://apt.brightbox.net/release.asc | apt-key add -")
dialog.progress(100)


# Update and install APT packages
dialog.message("Will now install required APT packages")
system "apt-get update
        apt-get install \
          ruby ruby-dev rubygems rails quota \
          apache2 php5 libapache2-mod-passenger \
          mysql-server php5-mysql libmysql-ruby"


# Install requires Gems
dialog.message("Will now install required Gems")
#system "gem install rails -v 2.3.4 --no-rdoc --no-ri"
#system "gem install fastthread --no-rdoc --no-ri"


# Configure Apache
dialog.progress(0, "Configure Apache")
File.open("#{cfg["apache_etc"]}/sites-available/ohm", "w") { |f|
  f.print "<VirtualHost *:80>\n"
  f.print "  RailsEnv development\n"                                            ### LIGNE A ENLEVER APRES TESTS !!!
  f.print "  DocumentRoot $PANEL_PATH/public\n"
  f.print "  <Directory $PANEL_PATH/public>\n"
  f.print "    Allow from all\n"
  f.print "    Options FollowSymLinks -MultiViews\n"
  f.print "  </Directory>\n"
  f.print "</VirtualHost>\n"
}
File.open("#{cfg["apache_etc"]}/apache2.conf", "w") { |f|
  f.print File.read("#{cfg["apache_etc"]}/apache2.conf")
  f.print "ServerName 0.0.0.0\n"
  f.print "NameVirtualHost *:80\n"
}
dialog.progress(25)
system "a2ensite ohm"
dialog.progress(50)
system "a2dissite default"
dialog.progress(75)
system "service apache2 restart"
dialog.progress(100)

dialog.exit

