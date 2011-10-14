class AddUserToLoggedUser < ActiveRecord::Migration
  def self.up
    add_column :logged_users, :user_id, :integer
  end

  def self.down
    remove_column :logged_users, :user_id
  end
end

