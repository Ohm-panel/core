class CreateServiceEmailUsers < ActiveRecord::Migration
  def self.up
    create_table :service_email_users do |t|
      t.integer :user_id
      t.integer :max_mailboxes
      t.integer :max_aliases

      t.timestamps
    end
  end

  def self.down
    drop_table :service_email_users
  end
end
