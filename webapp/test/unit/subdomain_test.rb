# Subdomain test
require 'test_helper'

class SubdomainTest < ActiveSupport::TestCase
  test "valid fixtures" do
    assert subdomains(:one).valid?, "fixtures: one is invalid"
    assert subdomains(:two).valid?, "fixtures: two is invalid"
  end

  test "invalid without url or domain" do
    sub = Subdomain.new
    sub.save
    assert sub.errors.invalid?(:url), "valid without url"
    assert sub.errors.invalid?(:domain), "valid without domain"
    assert !sub.errors.invalid?(:path), "invalid without path, should default to url"
    assert !sub.errors.invalid?(:mainsub), "invalid without mainsub, should default to false and pass"
  end

  test "duplicate url or path" do
    sub = Subdomain.new(:url        => subdomains(:one).url,
                        :domain_id  => subdomains(:one).domain_id,
                        :path       => subdomains(:one).path)
    sub.save
    assert sub.errors.invalid?(:url), "valid with duplicate url"
    assert sub.errors.invalid?(:path), "valid with duplicate path"

    sub.domain_id = 2
    assert sub.valid?, "invalid with duplicate url and path but different domains"

    sub.domain_id = 1
    sub.url = "newsub"
    sub.path = "newsub"
    assert sub.valid?, "invalid with non-duplicate url and path"
  end

  test "one mainsub per domain" do
    sub = Subdomain.new(:url        => 'mainsub',
                        :domain_id  => 1,
                        :path       => 'mainsub',
                        :mainsub    => true)
    sub.save
    assert sub.valid?, "invalid with mainsub = true"
    assert sub.domain.subdomains.select {|s| s.mainsub}.count == 1, "more than one subdomain"
  end

  test "mainsub should default to false" do
    sub = subdomains(:two)
    sub.mainsub = nil
    sub.save
    assert sub.valid?, "invalid with blank mainsub, should default to false and pass"
    assert sub.mainsub == false, "blank mainsub should default to false"
  end

  test "path should default to url" do
    sub = subdomains(:one)
    sub.path = ""
    sub.save
    assert sub.valid?, "Blank path rejected, should default to url"
    assert sub.path == sub.url, "Blank path not defaulted to url"
  end
end

