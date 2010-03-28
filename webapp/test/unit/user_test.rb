require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "valid fixtures" do
    assert users(:root).valid?, "fixtures: root is invalid"
    assert users(:root).root?, "fixtures: root is not root"

    assert users(:one).valid?, "fixtures: one is invalid"
    assert users(:two).valid?, "fixtures: two is invalid"
  end

  test "invalid without username, password or email" do
    user = User.new
    user.parent = users(:root)
    user.save
    assert user.errors.invalid?(:username), "Blank username valid"
    assert user.errors.invalid?(:password), "Blank password valid"
    assert user.errors.invalid?(:email), "Blank email valid"
  end

  test "email should have good format" do
    user = User.new(:username => "test_email",
                    :password => "x",
                    :email    => "valid@email.com",
                    :parent   => users(:root))
    assert user.valid?, "Good user not valid"

    user.email = "valid.with.dots_and-stuff@123.test.co.uk"
    user.save
    assert user.valid?, "Good e-mail not valid"

    user.email = "invalid@email"
    user.save
    assert user.errors.invalid?(:email), "invalid@email accepted as e-mail address"

    user.email = "invalid_too"
    user.save
    assert user.errors.invalid?(:email), "invalid_too accepted as e-mail address"
  end

  test "username must be unique" do
    user = User.new(:username => users(:one).username,
                    :password => "x",
                    :email    => "valid@email.com",
                    :parent   => users(:root))
    user.save
    assert user.errors.invalid?(:username), "Username from existing user valid"
  end

  test "os reserved usernames" do
    user = User.new(:username => "admin",
                    :password => "x",
                    :email    => "valid@email.com",
                    :parent   => users(:root))
    user.save
    assert user.errors.invalid?(:username), "OS reserved username valid"

    user.username = "nobody"
    user.save
    assert user.errors.invalid?(:username), "OS reserved username valid"
  end

  test "password change" do
    user = users(:one)
    user.old_password = "test1"
    user.password = "new password"
    user.password_confirmation = "new password"
    assert user.valid?, "Refused password change with good password"
  end

  test "invalid password in password change" do
    user = users(:one)
    user.old_password = "incorrect password"
    user.password = "new password"
    user.password_confirmation = "new password"
    user.save
    assert user.errors.invalid?(:old_password), "Accepted incorrect old_password"
  end

  test "confirmation desn't match new password in password change" do
    user = users(:one)
    user.old_password = "test1"
    user.password = "aaa"
    user.password_confirmation = "bbb"
    user.save
    assert user.errors.invalid?(:password_confirmation), "Accepted unmatching password and confirmation"
  end

  test "invalid quotas" do
    user = User.new(:username       => "quota tester",
                    :password       => "x",
                    :email          => "valid@email.com",
                    :parent         => users(:one),
                    :max_space      => users(:one).free_space + 1,
                    :max_subdomains => users(:one).free_subdomains + 1,
                    :max_subusers   => users(:one).free_subusers + 1)
    user.save
    assert user.errors.invalid?(:max_space), "Accepted too big max_space"
    assert user.errors.invalid?(:max_subdomains), "Accepted too big max_subdomains"
    assert user.errors.invalid?(:max_subusers), "Accepted too big max_subusers"
  end
end

