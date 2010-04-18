class AddDaemonToServices < ActiveRecord::Migration
  def self.up
    add_column :services, :daemon_installed, :boolean, :default => false
  end

  def self.down
    remove_column :services, :daemon_installed
  end
end

