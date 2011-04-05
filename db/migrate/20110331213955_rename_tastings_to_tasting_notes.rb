class RenameTastingsToTastingNotes < ActiveRecord::Migration
  def self.up
    #rename_table :tastings, :tasting_notes
    
    # We need to update all of the events
    Event.where(:source_type => 'Tasting').each { |e| e.update_attribute(:source_type, 'TastingNote') }
    
    # Also, add a bunch of fields to the tasting notes while we're here
    add_column :tasting_notes, :pour_rating, :integer, :default => 0
    add_column :tasting_notes, :aroma_rating, :integer, :default => 0
    add_column :tasting_notes, :taste_rating, :integer, :default => 0
    add_column :tasting_notes, :appearance_rating, :integer, :default => 0
    add_column :tasting_notes, :mouthfeel_rating, :integer, :default => 0
    add_column :tasting_notes, :drinkability_rating, :integer, :default => 0
    add_column :tasting_notes, :preference_rating, :integer, :default => 0
  end

  def self.down
    # Also, add a bunch of fields to the tasting notes while we're here
    remove_column :tasting_notes, :pour_rating
    remove_column :tasting_notes, :aroma_rating
    remove_column :tasting_notes, :taste_rating
    remove_column :tasting_notes, :appearance_rating
    remove_column :tasting_notes, :mouthfeel_rating
    remove_column :tasting_notes, :drinkability_rating
    remove_column :tasting_notes, :preference_rating
    
    Event.where(:source_type => 'TastingNote').each { |e| e.update_attribute(:source_type, 'Tasting') }
    
    #rename_table :tasting_notes, :tastings
  end
end
