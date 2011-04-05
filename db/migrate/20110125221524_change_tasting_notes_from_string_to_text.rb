class ChangeTastingNotesFromStringToText < ActiveRecord::Migration
  def self.up
    change_column :tasting_notes, :notes, :text
    change_column :beers, :notes, :text
    change_column :beers, :notes, :text
    change_column :brews, :description, :text
  end

  def self.down
    change_column :tasting_notes, :notes, :string
    change_column :beers, :notes, :string
    change_column :beers, :notes, :string
    change_column :brews, :description, :string
  end
end
