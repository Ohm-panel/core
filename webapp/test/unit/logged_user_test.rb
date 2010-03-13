require 'test_helper'

class LoggedUserTest < ActiveSupport::TestCase
  test "valid fixtures" do
    assert logged_users(:one).valid?, "fixtures: one is invalid"
  end

   test "invalid without session, session_ts, ip or user_id" do
    lu = LoggedUser.new
    lu.save
    assert lu.errors.invalid?(:session), "Blank session valid"
    assert lu.errors.invalid?(:session_ts), "Blank session_ts valid"
    assert lu.errors.invalid?(:user_id), "Blank user valid"
    assert lu.errors.invalid?(:ip), "Blank ip valid"
  end

  test "ip formats" do
    lu = logged_users(:one)
    lu.ip = "91.121.172.141"
    assert lu.valid?, "Good ip rejected"

    lu.ip = "256.0.0.0"
    lu.save
    assert lu.errors.invalid?(:ip), "Bad ip accepted"

    lu.ip = "1.0.0.300"
    lu.save
    assert lu.errors.invalid?(:ip), "Bad ip accepted"

    lu.ip = "1.1.1"
    lu.save
    assert lu.errors.invalid?(:ip), "Bad ip accepted"
  end

  test "ts in the future" do
    lu = logged_users(:one)
    lu.session_ts = Time.new + 10
    lu.save
    assert lu.errors.invalid?(:session_ts), "Timestamp in 10 seconds accepted"
  end
end

