class CorrectSubdomains < ActiveRecord::Migration
  def self.up
    remove_column :subdomains, :domain
    add_column :subdomains, :domain_id, :integer
  end

  def self.down
    remove_column :subdomains, :domain_id
    add_column :subdomains, :domain, :integer
  end
end

