class CreateUploadedBeerRecords < ActiveRecord::Migration
  def self.up
    create_table :uploaded_beer_records do |t|
      t.string :job_id
      t.string :brewery
      t.string :variety
      t.string :bottle_size
      t.string :quantity
      t.string :brew_style
      t.string :year
      t.string :cellared_at

      t.timestamps
    end
  end

  def self.down
    drop_table :uploaded_beer_records
  end
end
