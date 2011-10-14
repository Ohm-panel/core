# Configuration controller test
require 'test_helper'

class ConfigurationsControllerTest < ActionController::TestCase
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

  test "should get edit" do
    login_as users(:root)
    get :edit, :configuration => 1
    assert_response :success
  end

  test "should refuse edit" do
    login_as users(:one)
    get :edit, :configuration => 1
    assert_redirected_to :controller => 'dashboard'
    assert flash[:error]
  end
end

