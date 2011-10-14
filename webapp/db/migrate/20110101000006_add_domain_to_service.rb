class AddDomainToService < ActiveRecord::Migration
  def self.up
    add_column :services, :by_domain, :boolean
  end

  def self.down
    remove_column :services, :by_domain
  end
end

