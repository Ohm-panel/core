class RemoveOhmdStatusFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :ohmd_status
  end

  def self.down
    add_column :users, :ohmd_status, :integer
  end
end

