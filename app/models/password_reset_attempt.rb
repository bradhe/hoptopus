class PasswordResetAttempt < ActiveRecord::Base
  belongs_to :user
end
