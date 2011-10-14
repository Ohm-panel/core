class CreateConfigurations < ActiveRecord::Migration
  def self.up
    create_table :configurations do |t|
      t.boolean :enable_www, :default => true
      t.boolean :enable_dns, :default => true
      t.boolean :enable_ssh, :default => true
      t.string :ip_address

      t.timestamps
    end
  end

  def self.down
    drop_table :configurations
  end
end
