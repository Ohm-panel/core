class AddMigrationsToServices < ActiveRecord::Migration
  def self.up
    add_column :services, :migrations, :string
  end

  def self.down
    remove_column :services, :migrations
  end
end

