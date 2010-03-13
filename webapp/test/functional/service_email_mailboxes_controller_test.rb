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

