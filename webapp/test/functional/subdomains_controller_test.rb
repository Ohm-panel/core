### Ohm - Open Hosting Manager <http://joelcogen.com/projects/ohm/> ###
#
# Subdomains controller test
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

class SubdomainsControllerTest < ActionController::TestCase
  test "should get login" do
    get :index
    assert_redirected_to :controller => 'login', :action => 'index'
  end

  test "should get new" do
    login_as users(:root)
    get :new, :domain => domains(:one).to_param
    assert_response :success
  end

  test "should refuse new" do
    login_as users(:one)
    get :new, :domain => domains(:one).to_param
    assert_redirected_to domains_path
    assert flash[:error]
  end

  test "should create subdomain" do
    login_as users(:root)
    assert_difference('Subdomain.count') do
      post :create, :subdomain => { :url => "newsub", :domain => domains(:one) }
    end

    assert_redirected_to domain_path(assigns(:subdomain).domain)
    assert flash[:error].nil?
  end

  test "should refuse to create subdomain" do
    login_as users(:one)
    assert_difference('Subdomain.count', 0) do
      post :create, :subdomain => { :url => "newsub", :domain => domains(:one) }
    end

    assert_redirected_to domains_path
    assert flash[:error]
  end

  test "should get edit" do
    login_as users(:root)
    get :edit, :id => subdomains(:one).to_param
    assert_response :success
  end

  test "should refuse to edit" do
    login_as users(:one)
    get :edit, :id => subdomains(:one).to_param
    assert_redirected_to domains_path
    assert flash[:error]
  end

  test "should update subdomain" do
    login_as users(:root)
    put :update, :id => subdomains(:one).to_param, :subdomain => { :url => "newurl" }
    assert_redirected_to domain_path(assigns(:subdomain).domain)
    assert flash[:error].nil?
  end

  test "should refuse to update subdomain" do
    login_as users(:one)
    put :update, :id => subdomains(:one).to_param, :subdomain => { :url => "newurl" }
    assert_redirected_to domains_path
    assert flash[:error]

    # Changing domain is not allowed
    login_as users(:root)
    put :update, :id => subdomains(:one).to_param, :subdomain => { :url => "newurl", :domain => domains(:one) }
    assert_redirected_to domains_path
    assert flash[:error]
  end

  test "should destroy subdomain" do
    login_as users(:root)
    assert_difference('Subdomain.count', -1) do
      delete :destroy, :id => subdomains(:one).to_param
    end

    assert_redirected_to domain_path(subdomains(:one).domain)
    assert flash[:error].nil?

    # Should refuse to destroy last subdomain
    assert_difference('Subdomain.count', 0) do
      delete :destroy, :id => subdomains(:two).to_param
    end

    assert_redirected_to domain_path(subdomains(:one).domain)
    assert flash[:error]
  end

  test "should refuse to destroy subdomain" do
    login_as users(:one)
    assert_difference('Subdomain.count', 0) do
      delete :destroy, :id => subdomains(:one).to_param
    end

    assert_redirected_to domains_path
    assert flash[:error]
  end
end

