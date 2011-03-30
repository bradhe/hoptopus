class CreateConfirmationRequests < ActiveRecord::Migration
  def self.up
    create_table :confirmation_requests do |t|
      t.integer :user_id
      t.string :confirmation_code
      t.boolean :confirmed, :default => false
      t.boolean :expired, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :confirmation_requests
  end
end
