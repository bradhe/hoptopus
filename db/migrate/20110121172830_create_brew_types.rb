class CreateBrewTypes < ActiveRecord::Migration
  def self.up
    create_table :brew_types do |t|
      t.string :name

      t.timestamps
    end
	
	brew_types = ['Brown','Pale','Old','Stout','Wit','Wheat', 'India Pale Ale','Porter','Scotch Ale','Pilsener', 'Lager','Oatmeal Stout','Hard Cider','Pear Cider','Imperial Stout']
	brew_types.each do |b|
		BrewType.new(:name => b).save
	end
  end

  def self.down
    drop_table :brew_types
  end
end
