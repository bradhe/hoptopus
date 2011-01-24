class AddRemovedAtToBeer < ActiveRecord::Migration
  def self.up
    add_column :beers, :removed_at, :datetime
  end

  def self.down
    remove_column :beers, :removed_at
  end
end
