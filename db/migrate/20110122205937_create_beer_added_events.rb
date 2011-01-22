class CreateBeerAddedEvents < ActiveRecord::Migration
  def self.up
    create_table :beer_added_events do |t|
      t.integer :beer_id
      t.integer :event_id

      t.timestamps
    end
  end

  def self.down
    drop_table :beer_added_events
  end
end
