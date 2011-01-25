class AddConfirmedToPasswordResetAttempts < ActiveRecord::Migration
  def self.up
    add_column :password_reset_attempts, :confirmed, :boolean, :default => false
    
    PasswordResetAttempt.all.each do |p|
      p.confirmed = false
      p.save
    end
  end

  def self.down
    remove_column :password_reset_attempts, :confirmed
  end
end
