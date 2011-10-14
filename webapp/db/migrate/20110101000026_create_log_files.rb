class CreateLogFiles < ActiveRecord::Migration
  def self.up
    create_table :log_files do |t|
      t.string :name
      t.string :path

      t.timestamps
    end
  end

  def self.down
    drop_table :log_files
  end
end
