class CreateBeers < ActiveRecord::Migration
  def self.up
    create_table :beers do |t|
      t.integer :brew_id
      t.float :abv
      t.float :price
      t.string :size
      t.integer :quantity

      t.timestamps
    end
  end

  def self.down
    drop_table :beers
  end
end
