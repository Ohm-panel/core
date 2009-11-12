class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :username
      t.string :password
      t.string :full_name
      t.string :email
      t.integer :parent_id

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
