class CreateBrews < ActiveRecord::Migration
  def self.up
    create_table :brews do |t|
      t.string :name
      t.integer :brewery_id

      t.timestamps
    end
  end

  def self.down
    drop_table :brews
  end
end
