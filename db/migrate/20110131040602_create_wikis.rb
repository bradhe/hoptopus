class CreateWikis < ActiveRecord::Migration
  def self.up
    create_table :wikis do |t|
      t.integer :for_id
      t.string :for_type
      t.text :markup
      t.integer :revision

      t.timestamps
    end
    
    Brew.all.each do |b|
      b.markup = b.description
      b.save
    end
    
    Beer.all.each do |b|
      b.markup = b.notes
      b.save
    end
    
    TastingNote.all.each do |t|
      t.markup = t.notes
      t.save
    end
    
    remove_column :tasting_notes, :notes
    remove_column :beers, :notes
    remove_column :brews, :description
  end

  def self.down
    add_column :tasting_notes, :notes, :text
    
    TastingNote.all.each do |t|
      t.notes = t.markup
      t.save
    end
    
    add_column :beers, :notes, :text
    
    Beer.all.each do |b|
      b.notes = b.markup
      b.save
    end
    
    add_column :brews, :description, :text
    
    Brew.all.each do |b|
      b.description = b.markup
      b.save
    end
    
    drop_table :wikis
  end
end
