class AddUserToCellar < ActiveRecord::Migration
  def self.up
    add_column :cellars, :user_id, :integer
  end

  def self.down
    remove_column :cellars, :user_id
  end
end
