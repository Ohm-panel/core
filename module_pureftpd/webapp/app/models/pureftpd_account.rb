# Ohm - Open Hosting Manager <http://ohmanager.sourceforge.net>
# PureFTPd module - Account
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

require 'digest/sha2'

class PureftpdAccount < ActiveRecord::Base
  belongs_to :pureftpd_user
  belongs_to :domain

  def full_username
    self.username + '@' + self.domain.domain
  end

  validates_presence_of :pureftpd_user_id, :password, :username, :domain_id
  validates_format_of :username, :with => /\A[a-z][a-z0-9_-]*\Z/
  validates_format_of :root, :with => /\A[a-zA-Z0-9_\-\/.]*\Z/
  validates_uniqueness_of :username, :scope => :domain_id
  validate :passwords_match, :legal_domain

  attr_accessor :password_confirmation

  def passwords_match
    errors.add(:password_confirmation, "doesn't match password") if password_confirmation and password_confirmation != password
  end

  def legal_domain
    errors.add(:domain, "is not yours") unless pureftpd_user and pureftpd_user.user.domains.include? domain
  end

  def before_save
    self.password = User.shadow_password(password) if password_confirmation
  end
end

