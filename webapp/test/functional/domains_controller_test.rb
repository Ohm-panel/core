# Ohm - Open Hosting Manager <http://ohmanager.sourceforge.net>
# Domains controller test
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

class DomainsControllerTest < ActionController::TestCase
  test "should get login" do
    get :index
    assert_redirected_to :controller => 'login', :action => 'index'
  end

  test "should get index" do
    login_as users(:one)
    get :index
    assert_response :success
  end

  test "should get new" do
    login_as users(:one)
    get :new
    assert_response :success
  end

  test "should create domain" do
    login_as users(:one)
    assert_difference('Domain.count') do
      post :create, :domain => { :domain => "newdom.com" }
    end

    assert_redirected_to domain_path(assigns(:domain))
    assert flash[:error].nil?
  end

  test "should show domain" do
    login_as users(:root)
    get :show, :id => domains(:one).to_param
    assert_response :success
  end

  test "should refuse to show domain" do
    login_as users(:one)
    get :show, :id => domains(:one).to_param
    assert_redirected_to domains_path
    assert flash[:error]
  end

  test "should destroy domain" do
    login_as users(:root)
    assert_difference('Domain.count', -1) do
      delete :destroy, :id => domains(:one).to_param
    end

    assert_redirected_to domains_path
    assert flash[:error].nil?
  end

  test "should refuse to destroy domain" do
    login_as users(:one)
    assert_difference('Domain.count', 0) do
      delete :destroy, :id => domains(:one).to_param
    end

    assert_redirected_to domains_path
    assert flash[:error]
  end

  test "should add service" do
    login_as users(:root)
    services(:one).users << users(:root)
    services(:one).save
    assert_difference('domains(:one).services.count') do
      post :addservice, :domain_id => domains(:one).id, :service_id => [services(:one).id]
    end

    assert_redirected_to :controller => services(:one).controller, :action => 'addtodomain', :domain_id => domains(:one).id, :service_id => services(:one).id
  end

  test "should refuse to add service" do
    login_as users(:one)
    services(:one).users << users(:one)
    services(:one).save
    assert_difference('domains(:one).services.count', 0) do
      post :addservice, :domain_id => domains(:one).id, :service_id => [services(:one).id]
    end

    assert_redirected_to domains_path
    assert flash[:error]
  end
end

