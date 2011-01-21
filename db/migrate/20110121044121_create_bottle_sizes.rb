class CreateBottleSizes < ActiveRecord::Migration
  def self.up
    create_table :bottle_sizes do |t|
      t.string :name

      t.timestamps
    end
	
	BottleSize.new(:name => '12oz').save
	BottleSize.new(:name => '22oz').save
	BottleSize.new(:name => '25.4oz').save
	BottleSize.new(:name => '40oz').save
	BottleSize.new(:name => '64oz').save
	BottleSize.new(:name => '330ml').save
	BottleSize.new(:name => '341ml').save
	BottleSize.new(:name => '355ml').save
	BottleSize.new(:name => '375ml').save
  end

  def self.down
    drop_table :bottle_sizes
  end
end
