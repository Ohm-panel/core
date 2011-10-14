class CreateSubdomains < ActiveRecord::Migration
  def self.up
    create_table :subdomains do |t|
      t.string :url
      t.integer :domain
      t.string :path
      t.boolean :mainsub

      t.timestamps
    end
  end

  def self.down
    drop_table :subdomains
  end
end
