class User < ActiveRecord::Base
	has_one :cellar
	has_many :tastings
	
	validates_presence_of :email, :message => 'Please provide an email address.'
	validates_presence_of :username, :message => 'Please provide a username.'
	validates_presence_of :password_hash, :message => 'Please provide a password.'
	validates_confirmation_of :password_hash, :message => 'Passwords do not match.'
	validates_length_of :password_hash, :minimum => 4, :message => 'Passwords must be atleast 4 characters long.'
	validates_format_of :email, :with => /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}/, :message => 'That is not an email address!'
	validates_format_of :username, :with => /^\S+$/, :message => 'no spaces allowed in username!'
	validates_uniqueness_of :email, :case_sensitive => false, :message => 'There is already an account with that email address.'
	validates_uniqueness_of :username, :case_sensitive => false, :message => 'There is already an account with that username.'
	
	before_save do
		self.password_hash = Digest::SHA256.hexdigest(password_hash)
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
end
