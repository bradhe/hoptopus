class AddSanitizedNameToBrewery < ActiveRecord::Migration
  def self.up
    add_column :breweries, :sanitized_name, :string
    
    Brewery.all.each do |b|
      # This should fire the save callback and set the 
      # sanitized names
      b.save
    end
  end

  def self.down
    remove_column :breweries, :sanitized_name
  end
end
