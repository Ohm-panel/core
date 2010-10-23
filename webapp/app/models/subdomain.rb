### Ohm - Open Hosting Manager <http://joelcogen.com/projects/ohm/> ###
#
# Subdomain
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

class Subdomain < ActiveRecord::Base
  belongs_to :domain

  validates_presence_of :url, :domain
  validates_uniqueness_of :url, :scope => :domain_id
  validates_uniqueness_of :path, :scope => :domain_id

  validate :max_one_mainsub, :min_one_mainsub

  def max_one_mainsub
    if self.mainsub
      curmain = Subdomain.find(:first, :conditions=>{:domain_id => self.domain_id, :mainsub => true})
      if curmain && curmain != self
        curmain.mainsub = false
        curmain.save false
      end
    end
  end

  def min_one_mainsub
    if !self.mainsub and self.id and Subdomain.find(self.id).mainsub
      self.mainsub = true
    end
  end

  def before_save
    self.mainsub = false if self.mainsub.nil?
    self.path = self.url if self.path == ""
  end
end

