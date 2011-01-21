class RemoveBeerFromTasting < ActiveRecord::Migration
  def self.up
    remove_column :tastings, :beer_id, :integer
    add_column :tastings, :brew_id, :integer
    add_column :tastings, :cellared_at, :datetime
  end

  def self.down
    remove_column :tastings, :cellared_at
    remove_column :tastings, :brew_id
    add_column :tastings, :beer_id
  end
end
