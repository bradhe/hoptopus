class AddCellaredAtToBeers < ActiveRecord::Migration
  def self.up
    add_column :beers, :cellared_at, :datetime
  end

  def self.down
    remove_column :beers, :cellared_at
  end
end
