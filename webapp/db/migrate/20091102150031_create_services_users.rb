class CreateServicesUsers < ActiveRecord::Migration
  def self.up
    create_table :services_users, :id => false do |t|
      t.integer :user_id
      t.integer :service_id
    end
  end

  def self.down
    drop_table :services_users
  end
end

