### Ohm - Open Hosting Manager <http://joelcogen.com/projects/ohm/> ###
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

class InitializeLogs < ActiveRecord::Migration
  def self.up
    LogFile.create :name => "Ohm web panel", :path => "/var/www/ohm/log/production.log"
    LogFile.create :name => "Ohm daemon", :path => "/var/log/ohmd.log"
    LogFile.create :name => "Apache error", :path => "/var/log/apache2/error.log"
    LogFile.create :name => "Apache access", :path => "/var/log/apache2/access.log"
    LogFile.create :name => "Syslog", :path => "/var/log/syslog"
  end

  def self.down
  end
end
