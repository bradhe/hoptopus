class AddOrderToBottleSizes < ActiveRecord::Migration
  def self.up
    add_column :bottle_sizes, :sort_order, :integer
    
    i = 1
    BottleSize.all.each do |b|
      b.sort_order = i
      b.save
      
      i += 1
    end
  end

  def self.down
    remove_column :bottle_sizes, :sort_order
  end
end
