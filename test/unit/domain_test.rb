require 'test_helper'

class DomainTest < ActiveSupport::TestCase
  test "valid fixtures" do
    assert domains(:one).valid?, "fixtures: one is invalid"
  end

  test "invalid without domain or user" do
    domain = Domain.new
    domain.save
    assert domain.errors.invalid?(:domain), "Blank domain valid"
    assert domain.errors.invalid?(:user), "Blank user valid"
  end

  test "domain must be unique" do
    domain = Domain.new(:domain => domains(:one).domain,
                        :user   => users(:one))
    domain.save
    assert domain.errors.invalid?(:domain), "Duplicate domain accepted"
  end
end

