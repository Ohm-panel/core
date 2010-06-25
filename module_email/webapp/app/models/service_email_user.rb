# Ohm - Open Hosting Manager <http://ohmanager.sourceforge.net>
# E-mail module - User
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

class ServiceEmailUser < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :user_id
  validates_uniqueness_of :user_id

  def used_mailboxes_total
    # What user uses
    used = 0
    self.user.domains.each do |dom|
      used += ServiceEmailMailbox.find(:all, :conditions => { :domain_id => dom.id, :forward_only => false }).count
    end
    # What's given to sub-users
    self.user.users.each do |u|
      mailuser = ServiceEmailUser.find(:first, :conditions => { :user_id => u.id })
      used += mailuser ? mailuser.max_mailboxes : 0
    end
    used
  end

  def used_aliases_total
    # What user uses
    used = 0
    self.user.domains.each do |dom|
      used += ServiceEmailMailbox.find(:all, :conditions => { :domain_id => dom.id, :forward_only => true }).count
    end
    # What's given to sub-users
    self.user.users.each do |u|
      mailuser = ServiceEmailUser.find(:first, :conditions => { :user_id => u.id })
      used += mailuser ? mailuser.max_aliases : 0
    end
    used
  end

  def free_mailboxes
    return -1 if self.max_mailboxes == -1
    self.max_mailboxes - self.used_mailboxes_total
  end

  def free_aliases
    return -1 if self.max_aliases == -1
    self.max_aliases - self.used_aliases_total
  end

  validate :check_quota

  def check_quota
    return if self.user.nil? # Rejected anyway, don't need to crash here

    # Fill blank quotas
    self.max_mailboxes = -1 if !self.max_mailboxes or self.max_mailboxes < 0
    self.max_aliases = -1 if !self.max_aliases or self.max_aliases < 0

    # Root can do anything
    return if self.user.root?
    return if self.user.parent.root?

    # Compute quotas to take from parent
    oldme = self.id ? ServiceEmailUser.find(self.id) : nil
    mailboxes_to_take = self.max_mailboxes - ((oldme and self.max_mailboxes!=-1) ? oldme.max_mailboxes : 0)
    aliases_to_take = self.max_aliases - ((oldme and self.max_aliases!=-1) ? oldme.max_aliases : 0)

    # See if we can take that much
    parent = ServiceEmailUser.find(:first, :conditions => { :user_id => self.user.parent.id })
    errors.add(:max_mailboxes, "is more than you can give") unless User.quota_ok parent.free_mailboxes, mailboxes_to_take
    errors.add(:max_aliases, "is more than you can give") unless User.quota_ok parent.free_aliases, aliases_to_take
  end
end

