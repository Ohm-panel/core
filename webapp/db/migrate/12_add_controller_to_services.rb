class AddControllerToServices < ActiveRecord::Migration
  def self.up
    add_column :services, :controller, :string
  end

  def self.down
    remove_column :services, :controller
  end
end

