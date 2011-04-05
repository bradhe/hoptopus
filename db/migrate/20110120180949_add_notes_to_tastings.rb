class AddNotesToTastings < ActiveRecord::Migration
  def self.up
    add_column :tasting_notes, :notes, :string
  end

  def self.down
    remove_column :tasting_notes, :notes
  end
end
