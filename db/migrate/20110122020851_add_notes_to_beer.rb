class AddNotesToBeer < ActiveRecord::Migration
  def self.up
    add_column :beers, :notes, :string
  end

  def self.down
    remove_column :beers, :notes
  end
end
