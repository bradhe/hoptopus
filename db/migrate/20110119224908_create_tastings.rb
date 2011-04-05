class CreateTastings < ActiveRecord::Migration
  def self.up
    create_table :tasting_notes do |t|
      t.integer :beer_id
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :tasting_notes
  end
end
