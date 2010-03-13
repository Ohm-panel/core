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

