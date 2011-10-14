class CreateDomainsServices < ActiveRecord::Migration
  def self.up
    create_table :domains_services, :id => false do |t|
      t.integer :domain_id
      t.integer :service_id
    end
  end

  def self.down
    drop_table :domains_services
  end
end

