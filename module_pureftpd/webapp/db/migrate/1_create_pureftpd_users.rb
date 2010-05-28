class CreatePureftpdUsers < ActiveRecord::Migration
  def self.up
    create_table :pureftpd_users do |t|
      t.integer :user_id
      t.integer :max_accounts

      t.timestamps
    end
  end

  def self.down
    drop_table :pureftpd_users
  end
end
