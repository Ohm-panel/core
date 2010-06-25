# Ohm - Open Hosting Manager <http://ohmanager.sourceforge.net>
# PureFTPd module - Accounts controller test
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

class PureftpdAccountsControllerTest < ActionController::TestCase
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

  test "should create account" do
    login_as users(:root)
    assert_difference('PureftpdAccount.count') do
      post :create, :pureftpd_account => { :username => "newtest", :root => "", :password => "newpass", :password_confirmation => "newpass", :domain_id => 1 }
    end
    assert_redirected_to :controller => 'pureftpd_accounts', :action => 'index'
    assert flash[:error].nil?
  end

  test "should refuse to create account" do
    login_as users(:two)
    assert_difference('PureftpdAccount.count', 0) do
      post :create, :pureftpd_account => { :username => "newtest", :root => "", :password => "newpass", :password_confirmation => "newpass", :domain_id => 1 }
    end
    assert_redirected_to :controller => 'dashboard', :action => 'index'
  end

  test "should get edit" do
    login_as users(:root)
    get :edit, :id => pureftpd_accounts(:one).to_param
    assert_response :success
  end

  test "should refuse to edit" do
    login_as users(:one)
    get :edit, :id => pureftpd_accounts(:one).to_param
    assert_redirected_to :controller => 'pureftpd_accounts', :action => 'index'
    assert flash[:error]
  end

  test "should update account" do
    login_as users(:root)
    put :update, :id => pureftpd_accounts(:one).to_param, :pureftpd_account => { }
    assert_redirected_to :controller => 'pureftpd_accounts', :action => 'index'
    assert flash[:error].nil?
  end

  test "should refuse to update account" do
    login_as users(:one)
    put :update, :id => pureftpd_accounts(:one).to_param, :pureftpd_account => { }
    assert_redirected_to :controller => 'pureftpd_accounts', :action => 'index'
    assert flash[:error]
  end

  test "should destroy account" do
    login_as users(:root)
    assert_difference('PureftpdAccount.count', -1) do
      delete :destroy, :id => pureftpd_accounts(:one).to_param
    end
    assert_redirected_to :controller => 'pureftpd_accounts', :action => 'index'
    assert flash[:error].nil?
  end

  test "should refuse to destroy account" do
    login_as users(:one)
    assert_difference('PureftpdAccount.count', 0) do
      delete :destroy, :id => pureftpd_accounts(:one).to_param
    end
    assert_redirected_to :controller => 'pureftpd_accounts', :action => 'index'
    assert flash[:error]
  end
end

