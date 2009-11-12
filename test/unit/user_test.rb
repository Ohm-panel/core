require 'test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures :users

  test "invalid without username, password or email" do
    user = User.new
    assert user.invalid?
    assert user.errors.invalid?(:username)
    assert user.errors.invalid?(:password)
    assert user.errors.invalid?(:email)
    assert user.errors.count == 3
  end

  test "email should have good format" do
    user = User.new(:username => "test_email",
                    :password => "x",
                    :email    => "valid@email.com")
    assert user.valid?

    user.email = "valid.with.dots_and-stuff@123.test.co.uk"
    assert user.valid?

    user.email = "invalid@email"
    assert !user.valid?
    assert user.errors.invalid?(:email)
    assert user.errors.count == 1

    user.email = "invalid_too"
    assert !user.valid?
    assert user.errors.invalid?(:email)
    assert user.errors.count == 1
  end

  test "username must be unique" do
    user = User.new(:username => users(:one).username,
                    :password => "x",
                    :email    => "valid@email.com")
    assert user.invalid?
    assert user.errors.invalid?(:username)
    assert user.errors.count == 1
  end

  test "password change" do
    user = users(:one)
    user.password = "test1"
    user.new_password = "new password"
    user.new_password_confirmation = "new password"
    assert user.valid?
  end

  test "invalid password in password change" do
    user = users(:one)
    user.password = "incorrect password"
    user.new_password = "new password"
    user.new_password_confirmation = "new password"
    assert user.invalid?
    assert user.errors.invalid?(:password)
    assert user.errors.count == 1
  end

  test "confirmation desn't match new password in password change" do
    user = users(:one)
    user.password = "test1"
    user.new_password = "aaa"
    user.new_password_confirmation = "bbb"
    assert user.invalid?
    assert user.errors.invalid?(:new_password)
    assert user.errors.count == 1
  end
end

