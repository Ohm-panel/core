class CreatePureftpdAccounts < ActiveRecord::Migration
  def self.up
    create_table :pureftpd_accounts do |t|
      t.string :username
      t.string :password
      t.integer :pureftpd_user_id
      t.string :root
      t.integer :domain_id

      t.timestamps
    end
  end

  def self.down
    drop_table :pureftpd_accounts
  end
end
