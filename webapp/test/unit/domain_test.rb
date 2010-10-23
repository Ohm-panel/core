### Ohm - Open Hosting Manager <http://joelcogen.com/projects/ohm/> ###
#
# Domain test
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

require 'test_helper'

class DomainTest < ActiveSupport::TestCase
  test "valid fixtures" do
    assert domains(:one).valid?, "fixtures: one is invalid"
  end

  test "invalid without domain or user" do
    domain = Domain.new
    domain.save
    assert domain.errors.invalid?(:domain), "Blank domain valid"
    assert domain.errors.invalid?(:user), "Blank user valid"
  end

  test "domain must be unique" do
    domain = Domain.new(:domain => domains(:one).domain,
                        :user   => users(:one))
    domain.save
    assert domain.errors.invalid?(:domain), "Duplicate domain accepted"
  end
end

