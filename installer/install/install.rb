# Ohm - Open Hosting Manager
# Installer

require 'yaml'

# Load distribution configuration
@args = ARGV
cfg = YAML.load_file("install/#{@args.last}.yml")


#conn = OhmPanelConnection.new(cfg["panel_url"], cfg["passphrase"], cfg["os"])

## Brightbox repo for Phusion Passenger (mod_rails)
#echo "deb http://apt.brightbox.net hardy main" >> /etc/apt/sources.list.d/brightbox.list
#wget -q -O - http://apt.brightbox.net/release.asc | apt-key add -

## Update and install APT packages
#apt-get update
#apt-get install \
#    ruby ruby-dev rubygems rails quota \
#    apache2 php5 libapache2-mod-passenger \
#    mysql-server php5-mysql libmysql-ruby

## Install requires Gems
##gem install rails -v 2.3.4 --no-rdoc --no-ri ################################## LIGNES A DECOMMENTER !!!
##gem install fastthread --no-rdoc --no-ri

## Configure Apache
#echo "<VirtualHost *:80>" > "$ETC_APACHE/sites-available/ohm"
#echo "  RailsEnv development" >> "$ETC_APACHE/sites-available/ohm" ############# LIGNE A ENLEVER APRES TESTS !!!
#echo "  DocumentRoot $PANEL_PATH/public" >> "$ETC_APACHE/sites-available/ohm"
#echo "  <Directory $PANEL_PATH/public>" >> "$ETC_APACHE/sites-available/ohm"
#echo "    Allow from all" >> "$ETC_APACHE/sites-available/ohm"
#echo "    Options FollowSymLinks -MultiViews" >> "$ETC_APACHE/sites-available/ohm"
#echo "  </Directory>" >> "$ETC_APACHE/sites-available/ohm"
#echo "</VirtualHost>" >> "$ETC_APACHE/sites-available/ohm"

#echo "ServerName 0.0.0.0" >> "$ETC_APACHE/apache2.conf"
#echo "NameVirtualHost *:80" >> "$ETC_APACHE/apache2.conf"

#a2ensite ohm
#a2dissite default
#service apache2 restart

