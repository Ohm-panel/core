#!/bin/bash
#
# Ohm - Open Hosting Manager
# Installer for Ubuntu Server 9.10
#

DOWNLOAD_URL=""
PANEL_PATH="/home/joel/ohm/webpanel"
DAEMON_PATH="/home/joel/ohm/ohmd"
APACHE_SITES="/etc/apache2/sites-available"


# Must run as root
if ((`id -u` != 0)); then
    echo "Must run as root"
    exit 1
fi

# Brightbox repo for Phusion Passenger (mod_rails)
echo "deb http://apt.brightbox.net hardy main" > /etc/apt/sources.list.d/brightbox.list
wget -q -O - http://apt.brightbox.net/release.asc | apt-key add -

# Update and install APT packages
apt-get update
apt-get install \
    ruby ruby-dev rubygems rails \
    apache2 php5 libapache2-mod-passenger \
    mysql-server php5-mysql libmysql-ruby

# Install requires Gems
gem install rails -v 2.3.4 --no-rdoc --no-ri
gem install fastthread --no-rdoc --no-ri

# Configure Apache
echo "<VirtualHost *:80>" > "$APACHE_SITES/ohm"
echo "  DocumentRoot $PANEL_PATH" >> "$APACHE_SITES/ohm"
echo "  <Directory $PANEL_PATH>" >> "$APACHE_SITES/ohm"
echo "    Allow from all" >> "$APACHE_SITES/ohm"
echo "    Options FollowSymLinks -MultiViews" >> "$APACHE_SITES/ohm"
echo "  </Directory>" >> "$APACHE_SITES/ohm"
echo "</VirtualHost>" >> "$APACHE_SITES/ohm"
a2ensite ohm
a2dissite default
service apache2 restart

