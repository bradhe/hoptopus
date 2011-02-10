class AddBrewTypeToBrew < ActiveRecord::Migration
  def self.up
    add_column :brews, :brew_type_id, :integer
	
	Brew.all.each do |b|
		b.brew_type_id = 1
		b.save
	end
  end

  def self.down
    remove_column :brews, :brew_type_id
  end
end
