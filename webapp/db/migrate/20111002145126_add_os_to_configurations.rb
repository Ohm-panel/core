class AddOsToConfigurations < ActiveRecord::Migration
  def self.up
    add_column :configurations, :os, :string
  end

  def self.down
    remove_column :configurations, :os
  end
end
