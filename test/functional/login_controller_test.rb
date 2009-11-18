require 'test_helper'

class LoginControllerTest < ActionController::TestCase
  fixtures :users

  test "index" do
    get :index
    assert_response :success
  end

  test "good login" do
    user = users(:one)
    user.password = "test1"
    post :login, :user => user
    assert_redirected_to users_path
  end

  test "bad login" do
    user = users(:one)
    user.password = "bad password"
    post :login, :user => user
    assert_redirected_to :action => :index
  end
end

