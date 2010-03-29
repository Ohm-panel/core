#!/bin/bash
#
# Ohm - Open Hosting Manager
# Installer launcher for Ubuntu Server 10.04
#
echo "=== Ohm install launcher for Ubuntu 10.04 ==="

if ((`id -u` != 0)); then
    echo "Must run as root"
    exit 1
fi

echo "Checking installer dependencies..."
if [[ ! `which dialog` || ! `which ruby` ]]; then
    apt-get -y --force-yes install ruby dialog
fi

echo "Launching installer..."
ruby install/install.rb ubuntu1004

