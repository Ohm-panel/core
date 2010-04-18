class CreateConfigurations < ActiveRecord::Migration
  def self.up
    create_table :configurations do |t|
      t.boolean :enable_www
      t.boolean :enable_dns
      t.boolean :enable_ssh
      t.string :ip_address

      t.timestamps
    end
  end

  def self.down
    drop_table :configurations
  end
end
