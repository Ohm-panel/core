require 'test_helper'

class ServiceEmailMailboxTest < ActiveSupport::TestCase
  test "valid fixtures" do
    assert service_email_mailboxes(:local).valid?, "fixtures: local is invalid"
    assert service_email_mailboxes(:alias).valid?, "fixtures: alias is invalid"
  end

  test "invalid without address, domain or password" do
    mbox = ServiceEmailMailbox.new
    mbox.save
    assert mbox.errors.invalid?(:address), "Blank address accepted"
    assert mbox.errors.invalid?(:domain_id), "Blank domain accepted"
    assert mbox.errors.invalid?(:password), "Blank password accepted"
  end

  test "password change" do
    mbox = service_email_mailboxes(:local)
    mbox.password = "new password"
    mbox.password_confirmation = mbox.password
    assert mbox.valid?, "Good new password rejected"

    mbox.password_confirmation = "something else"
    mbox.save
    assert mbox.errors.invalid?(:password_confirmation), "Incorrect password confirmation accepted"
  end

  test "address format" do
    mbox = service_email_mailboxes(:local)
    mbox.address = "valid.email_address-ok"
    assert mbox.valid?, "Good address rejected"

    mbox.address = "invalid@address"
    mbox.save
    assert mbox.errors.invalid?(:address), "Bad address accepted"

    mbox.address = "invalid address"
    mbox.save
    assert mbox.errors.invalid?(:address), "Bad address accepted"
  end

  test "address unique for domain" do
    mbox = ServiceEmailMailbox.new(:address   => service_email_mailboxes(:local).address,
                                   :domain_id => service_email_mailboxes(:local).domain_id,
                                   :password  => "some password")
    mbox.save
    assert mbox.errors.invalid?(:address), "Duplicate address accepted"

    mbox.domain_id = 2
    assert mbox.valid?, "Duplicate address on different domain rejected"
  end
end

