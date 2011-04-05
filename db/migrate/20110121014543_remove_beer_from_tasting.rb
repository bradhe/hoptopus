class RemoveBeerFromTasting < ActiveRecord::Migration
  def self.up
    remove_column :tasting_notes, :beer_id
    add_column :tasting_notes, :brew_id, :integer
    add_column :tasting_notes, :cellared_at, :datetime
  end

  def self.down
    remove_column :tasting_notes, :cellared_at
    remove_column :tasting_notes, :brew_id
    add_column :tasting_notes, :beer_id
  end
end
