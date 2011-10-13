class RemoveDeletedFromServices < ActiveRecord::Migration
  def self.up
    remove_column :services, :deleted
    remove_column :services, :daemon_installed
    remove_column :services, :migrations
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
