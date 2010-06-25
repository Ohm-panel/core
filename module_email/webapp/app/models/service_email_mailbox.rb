# Ohm - Open Hosting Manager <http://ohmanager.sourceforge.net>
# E-mail module - Mailbox
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

class ServiceEmailMailbox < ActiveRecord::Base
  belongs_to :domain

  def full_address
    self.address + '@' + self.domain.domain
  end

  validates_presence_of :domain_id
  validates_presence_of :password, :unless => Proc.new { |m| m.forward_only }
  validates_format_of :address, :with => /\A([a-zA-Z0-9\._-]+)\Z/i
  validates_uniqueness_of :address, :scope => :domain_id
  validate :passwords_match

  attr_accessor :password_confirmation

  def passwords_match
    errors.add(:password_confirmation, "doesn't match password") if password_confirmation and password_confirmation != password
  end

  def before_save
    self.password = User.shadow_password(password).split("\\$").join("$") if password_confirmation
    self.size = self.domain.user.max_space if self.size.nil?

    # Verify MX DNS entries exist for the domain
    unless self.domain.dns_entries.select { |e| e.creator=="service_email" }.count > 0
      DnsEntry.new(:line => "@\tIN\tMX 5\tmx.#{self.domain.domain}.",
                   :add_ip => false,
                   :creator => "service_email",
                   :domain_id => self.domain_id).save
      ["mx", "mail", "smtp", "pop", "pop3", "imap", "webmail"].each do |sub|
        DnsEntry.new(:line => "#{sub}\tIN\tA",
                     :add_ip => true,
                     :creator => "service_email",
                     :domain_id => self.domain_id).save
      end
    end
  end

  def before_destroy
    # If we remove the last mailbox, no need for DNS entries
    if ServiceEmailMailbox.all.select { |m| m.domain_id==self.domain_id }.count == 1
      DnsEntry.all.select { |e| e.domain_id==self.domain_id && e.creator=="service_email" }.each do |d|
        d.destroy
      end
    end
  end
end

