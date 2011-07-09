class AddTextToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :text, :string
  end

  def self.down
    remove_column :events, :text
  end
end
