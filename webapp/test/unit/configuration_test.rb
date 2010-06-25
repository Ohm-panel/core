# Ohm - Open Hosting Manager <http://ohmanager.sourceforge.net>
# Configuration test
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

class ConfigurationTest < ActiveSupport::TestCase
  test "valid fixtures" do
    assert configurations(:one).valid?, "fixtures: one is invalid"
  end

  test "ip formats" do
    config = configurations(:one)
    config.ip_address = "91.121.172.141"
    assert config.valid?, "Good ip rejected"

    config.ip_address = "256.0.0.0"
    config.save
    assert config.errors.invalid?(:ip_address), "Bad ip accepted"

    config.ip_address = "1.0.0.300"
    config.save
    assert config.errors.invalid?(:ip_address), "Bad ip accepted"

    config.ip_address = "1.1.1"
    config.save
    assert config.errors.invalid?(:ip_address), "Bad ip accepted"
  end
end

