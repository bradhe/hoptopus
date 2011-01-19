class AddCellarToBrew < ActiveRecord::Migration
  def self.up
    add_column :brews, :cellar_id, :integer
  end

  def self.down
    remove_column :brews, :cellar_id
  end
end
