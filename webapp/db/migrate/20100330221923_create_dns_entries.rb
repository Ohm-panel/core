class CreateDnsEntries < ActiveRecord::Migration
  def self.up
    create_table :dns_entries do |t|
      t.integer :domain_id
      t.string :line
      t.boolean :add_ip
      t.string :creator
      t.string :creator_data

      t.timestamps
    end
  end

  def self.down
    drop_table :dns_entries
  end
end
