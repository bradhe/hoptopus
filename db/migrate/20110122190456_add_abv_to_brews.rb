class AddAbvToBrews < ActiveRecord::Migration
  def self.up
    add_column :brews, :abv, :float
  end

  def self.down
    remove_column :brews, :abv
  end
end
