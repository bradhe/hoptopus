class NewsletterSignup < ActiveRecord::Base
  validates_format_of :email, :with => /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}/, :message => 'That is not a valid email address.'
  validates_uniqueness_of :email, :case_sensitive => false, :message => 'Hmm it looks like you have already signed up!'
end
