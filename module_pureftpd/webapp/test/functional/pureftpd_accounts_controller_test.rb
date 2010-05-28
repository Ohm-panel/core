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

