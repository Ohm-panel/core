class CreateServiceEmailMailboxes < ActiveRecord::Migration
  def self.up
    create_table :service_email_mailboxes do |t|
      t.string :address
      t.integer :domain_id
      t.string :full_name
      t.integer :size
      t.string :password
      t.text :forward
      t.boolean :forward_only

      t.timestamps
    end
  end

  def self.down
    drop_table :service_email_mailboxes
  end
end
