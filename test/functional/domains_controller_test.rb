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
      post :addservice, :domain_id => domains(:one).id, :service_id => services(:one).id
    end

    assert_redirected_to :controller => services(:one).controller, :action => 'addtodomain'
  end

  test "should refuse to add service" do
    login_as users(:one)
    services(:one).users << users(:one)
    services(:one).save
    assert_difference('domains(:one).services.count', 0) do
      post :addservice, :domain_id => domains(:one).id, :service_id => services(:one).id
    end

    assert_redirected_to domains_path
    assert flash[:error]
  end
end

