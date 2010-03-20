#!/bin/bash

# Brightbox repo for Phusion Passenger (mod_rails)
echo "deb http://apt.brightbox.net hardy main" > /etc/apt/sources.list.d/brightbox.list
wget -q -O - http://apt.brightbox.net/release.asc | apt-key add -

# Update and install APT packages
apt-get update
apt-get install \
    ruby rubygems rails \
    apache2 php5 libapache2-mod-passenger \
    mysql-server php5-mysql libmysql-ruby

# Install requires Gems
gem install rails -v 2.3.4 --no-rdoc --no-ri
gem install fastthread --no-rdoc --no-ri

