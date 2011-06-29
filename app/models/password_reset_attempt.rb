class PasswordResetAttempt < ActiveRecord::Base
  belongs_to :user
  attr_accessor :user_email, :password
  before_save :validate_email
  before_update :validate_email_matches_user

  validates_format_of :user_email, :with => /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}/, :message => 'That is not an email address!', :on => :create

  # This is only important after the initial save.
  validates_length_of :password, :minimum => 4, :message => 'Passwords must be atleast 4 characters long.', :on => :update
  validates_presence_of :password, :message => 'Please provide a password.', :on => :update
  validates_confirmation_of :password, :message => 'Passwords do not match.', :on => :update

  def validate_email
    unless User.find(:first, :select => :id, :conditions => ["email = '#{user_email}'"])
      errors.add(:user_email, 'No user with that email address was found.')
    end

    errors.empty?
  end

  def validate_email_matches_user
    unless user.email == user_email
      errors.add(:user_email, "The email address doesn't match the security token")
    end

    errors.empty?
  end
end
