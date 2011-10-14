class AddTechnameToServices < ActiveRecord::Migration
  def self.up
    add_column :services, :tech_name, :string
  end

  def self.down
    remove_column :services, :tech_name
  end
end

