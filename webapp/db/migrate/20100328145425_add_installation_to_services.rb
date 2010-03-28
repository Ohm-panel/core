class AddInstallationToServices < ActiveRecord::Migration
  def self.up
    add_column :services, :install_files, :string
  end

  def self.down
    remove_column :services, :install_files
  end
end

