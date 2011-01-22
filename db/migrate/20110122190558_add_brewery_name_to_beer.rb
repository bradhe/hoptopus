class AddBreweryNameToBeer < ActiveRecord::Migration
  def self.up
    add_column :beers, :brewery_name, :string
    
    Beer.all.each do |b|
      b.brewery_name = b.brew.brewery.name
      b.save
    end
  end

  def self.down
    remove_column :beers, :brewery_name
  end
end
