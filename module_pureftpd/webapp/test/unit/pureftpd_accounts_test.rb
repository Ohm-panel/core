require 'test_helper'

class PureftpdAccountsTest < ActiveSupport::TestCase
  test "valid fixtures" do
    assert pureftpd_accounts(:one).valid?, "fixtures: one is invalid"
    assert pureftpd_accounts(:two).valid?, "fixtures: two is invalid"
  end

  test "invalid without username, password or domain" do
    acc = PureftpdAccount.new
    acc.save
    assert acc.errors.invalid?(:username), "Blank username accepted"
    assert acc.errors.invalid?(:password), "Blank password accepted"
    assert acc.errors.invalid?(:domain_id), "Blank domain accepted"
  end

  test "password change" do
    acc = pureftpd_accounts(:one)
    acc.password = "new password"
    acc.password_confirmation = acc.password
    assert acc.valid?, "Good new password rejected"

    acc.password_confirmation = "something else"
    acc.save
    assert acc.errors.invalid?(:password_confirmation), "Incorrect password confirmation accepted"
  end

  test "username format" do
    acc = pureftpd_accounts(:one)
    acc.username = "valid_username-ok"
    assert acc.valid?, "Good username rejected"

    acc.username = "000invalid_username"
    acc.save
    assert acc.errors.invalid?(:username), "Bad username accepted"

    acc.username = "invalid username"
    acc.save
    assert acc.errors.invalid?(:username), "Bad username accepted"

    acc.username = "invalid/username"
    acc.save
    assert acc.errors.invalid?(:username), "Bad username accepted"
  end

  test "username unique" do
    acc = PureftpdAccount.new(:username  => pureftpd_accounts(:one).username,
                              :password  => "some password",
                              :domain_id => pureftpd_accounts(:one).domain_id)
    acc.save
    assert acc.errors.invalid?(:username), "Duplicate username accepted"
  end
  
  test "illegal domain" do
    acc = pureftpd_accounts(:one)
    acc.domain_id = 2
    acc.save
    assert acc.errors.invalid?(:domain), "Illegal domain accepted"
  end
end

