class AddEmailConsentToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :email_consent, :boolean, :default => 0
  end

  def self.down
    remove_column :users, :email_consent
  end
end
