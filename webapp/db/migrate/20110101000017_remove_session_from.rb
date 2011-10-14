class RemoveSessionFrom < ActiveRecord::Migration
  def self.up
    remove_column :users, :session
    remove_column :users, :session_ts
  end

  def self.down
    add_column :users, :session, :string
    add_column :users, :session_ts, :datetime
  end
end

