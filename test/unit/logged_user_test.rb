require 'test_helper'

class LoggedUserTest < ActiveSupport::TestCase

  test "valid fixtures" do
    assert logged_users(:one).valid?, "fixtures: one is invalid"
  end

  # TO BE CONINUED...
end

