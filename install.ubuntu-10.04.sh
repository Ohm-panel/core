#!/bin/bash
#
### Ohm - Open Hosting Manager <http://joelcogen.com/projects/ohm/> ###
#
# Installer launcher for Ubuntu Server 10.04 LTS
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
ruby install/install.rb $1 ubuntu1004

