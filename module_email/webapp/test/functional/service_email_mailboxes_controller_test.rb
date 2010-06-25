# Ohm - Open Hosting Manager <http://ohmanager.sourceforge.net>
# E-mail module - Mailboxes controller test
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

class ServiceEmailMailboxesControllerTest < ActionController::TestCase
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

  test "should create mailbox" do
    login_as users(:root)
    assert_difference('ServiceEmailMailbox.count') do
      post :create, :service_email_mailbox => { :address => "newtest", :domain_id => 1, :password => "newpass", :password_confirmation => "newpass" }
    end
    assert_redirected_to :controller => 'service_email_mailboxes', :action => 'index'
    assert flash[:error].nil?
  end

  test "should refuse to create mailbox" do
    login_as users(:one)
    assert_difference('ServiceEmailMailbox.count', 0) do
      post :create, :service_email_mailbox => { :address => "newtest", :domain_id => 1, :password => "newpass", :password_confirmation => "newpass" }
    end
    assert_response :success # success veut dire qu'on render new, donc pas accepté
  end

  test "should get edit" do
    login_as users(:root)
    get :edit, :id => service_email_mailboxes(:local).to_param
    assert_response :success
  end

  test "should refuse to edit" do
    login_as users(:one)
    get :edit, :id => service_email_mailboxes(:local).to_param
    assert_redirected_to :controller => 'service_email_mailboxes', :action => 'index'
    assert flash[:error]
  end

  test "should update mailbox" do
    login_as users(:root)
    put :update, :id => service_email_mailboxes(:local).to_param, :service_email_mailbox => { }
    assert_redirected_to :controller => 'service_email_mailboxes', :action => 'index'
    assert flash[:error].nil?
  end

  test "should refuse to update mailbox" do
    login_as users(:one)
    put :update, :id => service_email_mailboxes(:local).to_param, :service_email_mailbox => { }
    assert_redirected_to :controller => 'service_email_mailboxes', :action => 'index'
    assert flash[:error]
  end

  test "should destroy mailbox" do
    login_as users(:root)
    assert_difference('ServiceEmailMailbox.count', -1) do
      delete :destroy, :id => service_email_mailboxes(:local).to_param
    end
    assert_redirected_to :controller => 'service_email_mailboxes', :action => 'index'
    assert flash[:error].nil?
  end

  test "should refuse to destroy mailbox" do
    login_as users(:one)
    assert_difference('ServiceEmailMailbox.count', 0) do
      delete :destroy, :id => service_email_mailboxes(:local).to_param
    end
    assert_redirected_to :controller => 'service_email_mailboxes', :action => 'index'
    assert flash[:error]
  end
end

