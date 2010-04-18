class AddOhmdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :ohmd_status, :integer
    add_column :users, :ohmd_password, :string
  end

  def self.down
    remove_column :users, :ohmd_status
    remove_column :users, :ohmd_password
  end
end

