class AddFacebookIdToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :facebook_id, :Integer
  end

  def self.down
    remove_column :users, :facebook_id
  end
end
