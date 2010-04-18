class AddPathToDomain < ActiveRecord::Migration
  def self.up
    add_column :domains, :path, :string
  end

  def self.down
    remove_column :domains, :path
  end
end

