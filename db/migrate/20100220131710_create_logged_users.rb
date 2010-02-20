class CreateLoggedUsers < ActiveRecord::Migration
  def self.up
    create_table :logged_users do |t|
      t.string :session
      t.datetime :session_ts
      t.string :ip

      t.timestamps
    end
  end

  def self.down
    drop_table :logged_users
  end
end
