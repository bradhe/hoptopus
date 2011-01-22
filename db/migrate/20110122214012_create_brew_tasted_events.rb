class CreateBrewTastedEvents < ActiveRecord::Migration
  def self.up
    create_table :brew_tasted_events do |t|
      t.integer :year
      t.integer :tasting_id
      t.integer :brew_id
      t.integer :event_id

      t.timestamps
    end
  end

  def self.down
    drop_table :brew_tasted_events
  end
end
