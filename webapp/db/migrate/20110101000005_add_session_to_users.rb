class AddSessionToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :session, :string
    add_column :users, :session_ts, :timestamp
  end

  def self.down
    remove_column :users, :session
    remove_column :users, :session_ts
  end
end

