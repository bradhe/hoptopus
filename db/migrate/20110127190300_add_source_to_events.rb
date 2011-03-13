class AddSourceToEvents < ActiveRecord::Migration
  include Hoptopus::EventFormatters
  
  def self.up
    add_column :events, :source_type, :string
    add_column :events, :source_id, :integer
    add_column :events, :formatter_type, :string
  end

  def self.down
    remove_column :events, :formatter_type
    remove_column :events, :source_id
    remove_column :events, :source_type
  end
end
