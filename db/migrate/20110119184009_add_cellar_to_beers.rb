class AddCellarToBeers < ActiveRecord::Migration
  def self.up
    add_column :beers, :cellar_id, :integer
  end

  def self.down
    remove_column :beers, :cellar_id
  end
end
