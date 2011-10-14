# Users controller test
require 'test_helper'

class UsersControllerTest < ActionController::TestCase
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

  test "should create user" do
    login_as users(:root)
    assert_difference('User.count') do
      post :create, :user => { :username => "newuser", :password => "newpassword", :email => "test@test.com" }
    end
    assert_redirected_to user_path(assigns(:user))
    assert flash[:error].nil?

    login_as users(:one)
    assert_difference('User.count') do
      post :create, :user => { :username => "secondnewuser", :password => "newpassword", :email => "test@test.com",
                               :max_space => 100, :max_subdomains => 1, :max_subusers => 1 }
    end
    assert_redirected_to user_path(assigns(:user))
    assert flash[:error].nil?
  end

  test "should show user" do
    login_as users(:root)
    get :show, :id => users(:one).to_param
    assert_response :success
  end

  test "should refuse to show user" do
    login_as users(:one)
    get :show, :id => users(:one).to_param
    assert_redirected_to users_path
    assert flash[:error]
  end

  test "should get edit" do
    login_as users(:root)
    get :edit, :id => users(:one).to_param
    assert_response :success
  end

  test "should refuse to edit" do
    login_as users(:one)
    get :edit, :id => users(:one).to_param
    assert_redirected_to users_path
    assert flash[:error]
  end

  test "should update user" do
    login_as users(:root)
    put :update, :id => users(:one).to_param, :user => { :full_name => "New name" }
    assert_redirected_to user_path(assigns(:user))
    assert flash[:error].nil?
  end

  test "should refuse to update user" do
    login_as users(:one)
    put :update, :id => users(:one).to_param, :user => { :full_name => "New name" }
    assert_redirected_to users_path
    assert flash[:error]
  end

  test "should get profile" do
    login_as users(:one)
    get :profile
    assert_response :success
  end

  test "should update profile" do
    login_as users(:one)
    post :profileupdate, :user => { :full_name => "New Name" }
    assert_redirected_to :controller => 'dashboard'
    assert flash[:error].nil?
  end

  test "should destroy user" do
    login_as users(:root)
    delete :destroy, :id => users(:one).to_param

    assert User.find_by_username(users(:one).username).deleted?

    assert_redirected_to users_path
    assert flash[:error].nil?
  end

  test "should refuse to destroy user" do
    login_as users(:one)
    assert_difference('User.count', 0) do
      delete :destroy, :id => users(:one).to_param
    end

    assert_redirected_to users_path
    assert flash[:error]
  end

  test "should add service" do
    login_as users(:root)
    services(:one).users << users(:root)
    services(:one).save

    assert_difference('users(:one).services.count') do
      post :addservice, :user_id => users(:one).id, :service_id => [services(:one).id]
    end

    assert_redirected_to :controller => services(:one).controller, :action => 'addtouser', :user_id => users(:one).id
    assert flash[:error].nil?
  end

  test "should refuse to add service" do
    login_as users(:one)
    services(:one).users << users(:one)
    services(:one).save

    assert_difference('users(:one).services.count', 0) do
      post :addservice, :user_id => users(:one).id, :service_id => [services(:one).id]
    end

    assert_redirected_to users_path
    assert flash[:error]
  end

  test "should remove service" do
    login_as users(:root)
    services(:one).users << users(:root)
    services(:one).save
    services(:one).users << users(:one)

    assert_difference('users(:one).services.count', -1) do
      post :removeservice, :user_id => users(:one).id, :service_id => services(:one).id
    end

    assert_redirected_to :controller => services(:one).controller, :action => 'removefromuser', :user_id => users(:one).id
    assert flash[:error].nil?
  end

  test "should refuse to remove service" do
    login_as users(:one)
    services(:one).users << users(:one)
    services(:one).save
    assert_difference('users(:one).services.count', 0) do
      post :removeservice, :user_id => users(:one).id, :service_id => services(:one).id
    end

    assert_redirected_to users_path
    assert flash[:error]
  end

  test "should login as user" do
    login_as users(:root)
    post :login_as_me, :id => users(:one).id
    assert_redirected_to :controller => 'dashboard'
    assert flash[:error].nil?
  end

  test "should refuse to login as user" do
    login_as users(:one)
    post :login_as_me, :id => users(:two).id
    assert_redirected_to users_path
    assert flash[:error]
  end
end

