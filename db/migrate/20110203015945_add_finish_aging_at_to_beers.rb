class AddFinishAgingAtToBeers < ActiveRecord::Migration
  def self.up
    add_column :beers, :finish_aging_at, :datetime
  end

  def self.down
    remove_column :beers, :finish_aging_at
  end
end
