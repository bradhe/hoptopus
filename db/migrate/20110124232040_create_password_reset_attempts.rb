class CreatePasswordResetAttempts < ActiveRecord::Migration
  def self.up
    create_table :password_reset_attempts do |t|
      t.integer :user_id
      t.string :security_token

      t.timestamps
    end
  end

  def self.down
    drop_table :password_reset_attempts
  end
end
