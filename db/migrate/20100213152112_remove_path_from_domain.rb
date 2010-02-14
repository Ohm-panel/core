class RemovePathFromDomain < ActiveRecord::Migration
  def self.up
    remove_column :domains, :path
  end

  def self.down
    add_column :domains, :path, :string
  end
end

