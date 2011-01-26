class AddShouldReceiveEmailNotificationsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :should_receive_email_notifications, :boolean, :default => true
    
    User.all.each do |u|
      u.should_receive_email_notifications = true
      u.save
    end
  end

  def self.down
    remove_column :users, :should_receive_email_notifications
  end
end
