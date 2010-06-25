# Ohm - Open Hosting Manager <http://ohmanager.sourceforge.net>
# Logged user test
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

class LoggedUserTest < ActiveSupport::TestCase
  test "valid fixtures" do
    assert logged_users(:one).valid?, "fixtures: one is invalid"
  end

   test "invalid without session, session_ts, ip or user_id" do
    lu = LoggedUser.new
    lu.save
    assert lu.errors.invalid?(:session), "Blank session valid"
    assert lu.errors.invalid?(:session_ts), "Blank session_ts valid"
    assert lu.errors.invalid?(:user_id), "Blank user valid"
    assert lu.errors.invalid?(:ip), "Blank ip valid"
  end

  test "ip formats" do
    lu = logged_users(:one)
    lu.ip = "91.121.172.141"
    assert lu.valid?, "Good ip rejected"

    lu.ip = "256.0.0.0"
    lu.save
    assert lu.errors.invalid?(:ip), "Bad ip accepted"

    lu.ip = "1.0.0.300"
    lu.save
    assert lu.errors.invalid?(:ip), "Bad ip accepted"

    lu.ip = "1.1.1"
    lu.save
    assert lu.errors.invalid?(:ip), "Bad ip accepted"
  end

  test "ts in the future" do
    lu = logged_users(:one)
    lu.session_ts = Time.new + 10
    lu.save
    assert lu.errors.invalid?(:session_ts), "Timestamp in 10 seconds accepted"
  end
end

