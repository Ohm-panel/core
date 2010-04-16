require 'test_helper'

class ConfigurationTest < ActiveSupport::TestCase
  test "valid fixtures" do
    assert configurations(:one).valid?, "fixtures: one is invalid"
  end

  test "ip formats" do
    config = configurations(:one)
    config.ip_address = "91.121.172.141"
    assert config.valid?, "Good ip rejected"

    config.ip_address = "256.0.0.0"
    config.save
    assert config.errors.invalid?(:ip_address), "Bad ip accepted"

    config.ip_address = "1.0.0.300"
    config.save
    assert config.errors.invalid?(:ip_address), "Bad ip accepted"

    config.ip_address = "1.1.1"
    config.save
    assert config.errors.invalid?(:ip_address), "Bad ip accepted"
  end
end
