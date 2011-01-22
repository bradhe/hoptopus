class AddDescriptionToBrew < ActiveRecord::Migration
  def self.up
    add_column :brews, :description, :string
  end

  def self.down
    remove_column :brews, :description
  end
end
