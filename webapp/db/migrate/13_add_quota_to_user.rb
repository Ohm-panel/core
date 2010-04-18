class AddQuotaToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :max_subdomains, :integer
    add_column :users, :max_space, :integer
    add_column :users, :max_bandwidth, :integer
    add_column :users, :max_subusers, :integer
  end

  def self.down
    remove_column :users, :max_subdomains
    remove_column :users, :max_space
    remove_column :users, :max_bandwidth
    remove_column :users, :max_subusers
  end
end

