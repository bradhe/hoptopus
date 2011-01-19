class AddYearToBeers < ActiveRecord::Migration
  def self.up
    add_column :beers, :year, :string
  end

  def self.down
    remove_column :beers, :year
  end
end
