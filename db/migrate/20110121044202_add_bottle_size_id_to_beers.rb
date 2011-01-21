class AddBottleSizeIdToBeers < ActiveRecord::Migration
  def self.up
    add_column :beers, :bottle_size_id, :int
	remove_column :beers, :size
  end

  def self.down
	add_column :beers, :size
    remove_column :beers, :bottle_size_id
  end
end
