# Ohm - Open Hosting Manager <http://ohmanager.sourceforge.net>
# E-mail module - Mailbox test
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

require 'test_helper'

class ServiceEmailMailboxTest < ActiveSupport::TestCase
  test "valid fixtures" do
    assert service_email_mailboxes(:local).valid?, "fixtures: local is invalid"
    assert service_email_mailboxes(:alias).valid?, "fixtures: alias is invalid"
  end

  test "invalid without address, domain or password" do
    mbox = ServiceEmailMailbox.new
    mbox.save
    assert mbox.errors.invalid?(:address), "Blank address accepted"
    assert mbox.errors.invalid?(:domain_id), "Blank domain accepted"
    assert mbox.errors.invalid?(:password), "Blank password accepted"
  end

  test "password change" do
    mbox = service_email_mailboxes(:local)
    mbox.password = "new password"
    mbox.password_confirmation = mbox.password
    assert mbox.valid?, "Good new password rejected"

    mbox.password_confirmation = "something else"
    mbox.save
    assert mbox.errors.invalid?(:password_confirmation), "Incorrect password confirmation accepted"
  end

  test "address format" do
    mbox = service_email_mailboxes(:local)
    mbox.address = "valid.email_address-ok"
    assert mbox.valid?, "Good address rejected"

    mbox.address = "invalid@address"
    mbox.save
    assert mbox.errors.invalid?(:address), "Bad address accepted"

    mbox.address = "invalid address"
    mbox.save
    assert mbox.errors.invalid?(:address), "Bad address accepted"

    mbox.address = "invalid+address"
    mbox.save
    assert mbox.errors.invalid?(:address), "Bad address accepted"
  end

  test "address unique for domain" do
    mbox = ServiceEmailMailbox.new(:address   => service_email_mailboxes(:local).address,
                                   :domain_id => service_email_mailboxes(:local).domain_id,
                                   :password  => "some password")
    mbox.save
    assert mbox.errors.invalid?(:address), "Duplicate address accepted"

    mbox.domain_id = 2
    assert mbox.valid?, "Duplicate address on different domain rejected"
  end
end

