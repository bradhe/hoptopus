class AddIbusToBrews < ActiveRecord::Migration
  def self.up
    add_column :brews, :ibus, :integer
  end

  def self.down
    remove_column :brews, :ibus
  end
end
