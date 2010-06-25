# Ohm - Open Hosting Manager <http://ohmanager.sourceforge.net>
# Dashboard controller test
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

class ServicesControllerTest < ActionController::TestCase
  test "should get login" do
    get :index
    assert_redirected_to :controller => 'login', :action => 'index'
  end

  test "should get index" do
    login_as users(:root)
    get :index
    assert_response :success
  end

  test "should refuse index" do
    login_as users(:one)
    get :index
    assert_redirected_to :controller => 'dashboard'
    assert flash[:error]
  end

  test "should get new" do
    login_as users(:root)
    get :new
    assert_response :success
  end

  test "should refuse new" do
    login_as users(:one)
    get :new
    assert_redirected_to :controller => 'dashboard'
    assert flash[:error]
  end

#  test "should create service" do
#    login_as users(:root)
#    assert_difference('Service.count') do
#      post :create, :service => { :name => "New service", :controller => "service_new_service" }
#    end

#    assert_redirected_to service_path(assigns(:service))
#    assert flash[:error].nil?
#  end

#  test "should refuse to create service" do
#    login_as users(:one)
#    assert_difference('Service.count', 0) do
#      post :create, :service => { :name => "New service", :controller => "service_new_service" }
#    end

#    assert_redirected_to :controller => 'dashboard'
#    assert flash[:error]
#  end

#  test "should destroy service" do
#    login_as users(:root)
#    assert_difference('Service.count', 0) do
#      delete :destroy, :id => services(:one).to_param
#    end
#
#    assert Service.find(services(:one)).deleted
#    assert_redirected_to services_path
#    assert flash[:error].nil?
#  end

  test "should refuse to destroy service" do
    login_as users(:one)
    assert_difference('Service.count', 0) do
      delete :destroy, :id => services(:one).to_param
    end

    assert_redirected_to :controller => 'dashboard'
    assert flash[:error]
  end
end

