class AddNameToBeer < ActiveRecord::Migration
  def self.up
    add_column :beers, :name, :string
    
    Beer.all.each do |b|
      b.name = b.brew.name
      b.save
    end
  end

  def self.down
    remove_column :beers, :name
  end
end
