#!/bin/bash
#
# Ohm - Open Hosting Manager
# Installer launcher for Ubuntu Server 9.10
#
echo "=== Ohm install launcher for Ubuntu 9.10 ==="

if ((`id -u` != 0)); then
    echo "Must run as root"
    exit 1
fi

echo "Checking installer dependencies..."
apt-get -y --force-yes install ruby dialog

echo "Launching installer..."
ruby install/install.rb ubuntu910
