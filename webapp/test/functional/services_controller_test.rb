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

  test "should show service" do
    login_as users(:root)
    get :show, :id => services(:one).to_param
    assert_response :success
  end

  test "should refuse to show service" do
    login_as users(:one)
    get :show, :id => services(:one).to_param
    assert_redirected_to :controller => 'dashboard'
    assert flash[:error]
  end

  test "should get edit" do
    login_as users(:root)
    get :edit, :id => services(:one).to_param
    assert_response :success
  end

  test "should refuse to get edit" do
    login_as users(:one)
    get :edit, :id => services(:one).to_param
    assert_redirected_to :controller => 'dashboard'
    assert flash[:error]
  end

  test "should update service" do
    login_as users(:root)
    put :update, :id => services(:one).to_param, :service => { }
    assert_redirected_to service_path(assigns(:service))
    assert flash[:error].nil?
  end

  test "should refuse to update service" do
    login_as users(:one)
    put :update, :id => services(:one).to_param, :service => { }
    assert_redirected_to :controller => 'dashboard'
    assert flash[:error]
  end

  test "should destroy service" do
    login_as users(:root)
    assert_difference('Service.count', -1) do
      delete :destroy, :id => services(:one).to_param
    end

    assert_redirected_to services_path
    assert flash[:error].nil?
  end

  test "should refuse to destroy service" do
    login_as users(:one)
    assert_difference('Service.count', 0) do
      delete :destroy, :id => services(:one).to_param
    end

    assert_redirected_to :controller => 'dashboard'
    assert flash[:error]
  end
end

