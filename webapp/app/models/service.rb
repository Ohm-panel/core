# Ohm - Open Hosting Manager <http://ohmanager.sourceforge.net>
# Service (module)
#
# Copyright (C) 2009-2010 UMONS <http://www.umons.ac.be>
#
# This file is part of Ohm.
#
# Ohm is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ohm is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ohm. If not, see <http://www.gnu.org/licenses/>.

class Service < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_and_belongs_to_many :domains

  validates_presence_of :name, :controller
  validates_uniqueness_of :name, :controller

  def active?
    self.daemon_installed && !self.deleted
  end

  def before_save
    self.by_domain = false if self.by_domain.nil?
    self.tech_name = self.name if self.tech_name.nil? or self.tech_name==""
  end
end

