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
  end

  def self.down
    drop_table :wikis
  end
end
