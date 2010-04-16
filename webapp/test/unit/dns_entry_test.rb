require 'test_helper'

class DnsEntryTest < ActiveSupport::TestCase
  test "valid fixtures" do
    assert dns_entries(:one).valid?, "fixtures: one is invalid"
  end
end
