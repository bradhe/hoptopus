class RemoveTextFromEvents < ActiveRecord::Migration
  def self.up
    remove_column :events, :text
    remove_column :events, :event_type
  end

  def self.down
    add_column :events, :text, :string
    add :events, :event_type, :int
  end
end
