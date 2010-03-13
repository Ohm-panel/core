require 'test_helper'

class ServiceTest < ActiveSupport::TestCase
  test "valid fixtures" do
    assert services(:one).valid?, "fixtures: one is invalid"
    assert services(:two).valid?, "fixtures: two is invalid"
  end

  test "invalid without name or controller" do
    s = Service.new
    s.save
    assert s.errors.invalid?(:name), "valid without name"
    assert s.errors.invalid?(:controller), "valid without controller"
  end

  test "name and controller must be unique" do
    s = Service.new(:name       => services(:one).name,
                    :controller => services(:one).controller)
    s.save
    assert s.errors.invalid?(:name), "valid with duplicate name"
    assert s.errors.invalid?(:controller), "valid with duplicate controller"
  end

  test "default values" do
    s = Service.new(:name       => "New Service",
                    :controller => "service_new_service")
    assert s.valid?, "invalid with just name and controller"
    s.save
    assert s.tech_name == s.name, "tech_name not defaulted to name"
    assert s.by_domain == false, "by_domain not defaulted to false"
  end
end

