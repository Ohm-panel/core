class AddDeletedToServices < ActiveRecord::Migration
  def self.up
    add_column :services, :deleted, :boolean, :default => false
  end

  def self.down
    remove_column :services, :deleted
  end
end

