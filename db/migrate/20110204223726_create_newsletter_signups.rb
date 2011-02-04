class CreateNewsletterSignups < ActiveRecord::Migration
  def self.up
    create_table :newsletter_signups do |t|
      t.string :email

      t.timestamps
    end
  end

  def self.down
    drop_table :newsletter_signups
  end
end
