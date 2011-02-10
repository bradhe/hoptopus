class AddNotesToTastings < ActiveRecord::Migration
  def self.up
    add_column :tastings, :notes, :string
  end

  def self.down
    remove_column :tastings, :notes
  end
end
