class AddUsedspaceToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :used_space, :integer
  end

  def self.down
    remove_column :users, :used_space
  end
end

