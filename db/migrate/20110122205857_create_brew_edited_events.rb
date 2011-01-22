class CreateBrewEditedEvents < ActiveRecord::Migration
  def self.up
    create_table :brew_edited_events do |t|
      t.integer :brew_id
      t.integer :event_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :brew_edited_events
  end
end
