class User < ActiveRecord::Base
	has_one :cellar, :dependent => :delete
	has_many :tastings
  has_many :events
  has_many :alerts
	
	validates_presence_of :email, :message => 'Please provide an email address.'
	validates_presence_of :username, :message => 'Please provide a username.'
  validates_length_of :username, :in => 4..16, :message => 'Usernames must be between 4 and 16 characters long.'
	validates_format_of :email, :with => /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}/, :message => 'That is not an email address!'
	validates_format_of :username, :with => /^\S+$/, :message => 'No spaces allowed in username.'
	validates_uniqueness_of :email, :case_sensitive => false, :message => 'There is already an account with that email address.'
	validates_uniqueness_of :username, :case_sensitive => false, :message => 'There is already an account with that username.'

  # We do not want to do these for OAuth clients
	validates_presence_of :password_hash, :message => 'Please provide a password.', :if => Proc.new { |u| u.facebook_id.nil? }
	validates_confirmation_of :password_hash, :message => 'Passwords do not match.', :if => Proc.new { |u| u.facebook_id.nil? }
	validates_length_of :password_hash, :minimum => 4, :message => 'Passwords must be atleast 4 characters long.', :if => Proc.new { |u| u.facebook_id.nil? }
	
	before_create do
    if password_hash
  		self.password_hash = hash_password(password_hash)
    end
	end

  def hash_password(password)
    Digest::SHA256.hexdigest(password)
  end
	
	def self.authenticate_without_password_hash(username, password)
		if password.nil? or password.empty?
			return nil
		end

		# Just hash the fucker and get outta here.
		password_hash = Digest::SHA256.hexdigest(password)

		return authenticate_with_password_hash(username, password_hash)
	end

	def self.authenticate_with_password_hash(username, password_hash)
		return find(:first, :conditions => "username = '#{username}' AND password_hash = '#{password_hash}'")
	end
  
  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    # Get the user email info from Facebook for sign up
    # You'll have to figure this part out from the json you get back
    data = ActiveSupport::JSON.decode(access_token)

    if user = User.find_by_email(data["email"])
      user
    else
      # Create an user with a stub password.
      User.create!(:name => data["name"], :email => data["email"], :password => Devise.friendly_token)
    end
  end
end
