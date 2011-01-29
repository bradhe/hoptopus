class AddSourceToEvents < ActiveRecord::Migration
  include Hoptopus::EventFormatters
  
  def self.up
    add_column :events, :source_type, :string
    add_column :events, :source_id, :integer
    add_column :events, :formatter_type, :string
    
    Event.all.each do |e|
      if not e.beer_added_events.empty?
        e.formatter = BeerAddedEventFormatter.new
        e.source = e.beer_added_events[0].beer
      elsif not e.brew_edited_events.empty?
        e.formatter = BrewEditEventFormatter.new
        e.source = e.brew_edited_events[0].brew
      elsif not e.brew_added_events.empty?
        e.formatter = BrewAddedEventFormatter.new
        e.source = e.brew_added_events[0].brew
      elsif not e.brew_tasted_events.empty?
        e.formatter = BrewTastedEventFormatter.new
        e.source = e.brew_tasted_events[0].tasting
      end
      
      e.save
    end
    
    drop_table :brew_edited_events
    drop_table :beer_added_events
    drop_table :brew_added_events
    drop_table :brew_tasted_events
  end

  def self.down
    remove_column :events, :formatter_type
    remove_column :events, :source_id
    remove_column :events, :source_type
  end
end
