### Ohm - Open Hosting Manager <http://joelcogen.com/projects/ohm/> ###
#
# Service (module) test
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

class ServiceTest < ActiveSupport::TestCase
  test "valid fixtures" do
    assert services(:one).valid?, "fixtures: one is invalid"
    assert services(:two).valid?, "fixtures: two is invalid"
  end

  test "invalid without name or controller" do
    s = Service.new
    s.save
    assert s.errors.invalid?(:name), "valid without name"
    assert s.errors.invalid?(:controller), "valid without controller"
  end

  test "name and controller must be unique" do
    s = Service.new(:name       => services(:one).name,
                    :controller => services(:one).controller)
    s.save
    assert s.errors.invalid?(:name), "valid with duplicate name"
    assert s.errors.invalid?(:controller), "valid with duplicate controller"
  end

  test "default values" do
    s = Service.new(:name       => "New Service",
                    :controller => "service_new_service")
    assert s.valid?, "invalid with just name and controller"
    s.save
    assert s.tech_name == s.name, "tech_name not defaulted to name"
    assert s.by_domain == false, "by_domain not defaulted to false"
  end
end

