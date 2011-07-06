class CreateWatchesTable < ActiveRecord::Migration
  def self.up
    create_table "watches", :id => false do |t|
      t.integer "user_id"
      t.integer "watching_user_id"
    end
    add_index(:watches, 'user_id')
  end

  def self.down
    remove_index(:watches, 'user_id')
    drop_table "watches"
  end
end
