class AddShouldShowOwnEventsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :should_show_own_events, :boolean, :default => true
		
		User.all.each do |u| 
			u.should_show_own_events = true
			u.save
		end
  end

  def self.down
    remove_column :users, :should_show_own_events
  end
end
