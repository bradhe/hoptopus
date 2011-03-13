class NewsletterController < ApplicationController
  def signup
    newsletter_signup = NewsletterSignup.new :email => params[:email]
    
    respond_to do |format|
      if newsletter_signup.save
        Notifications.newsletter_signup(params[:email]).deliver
        
        format.json { render :json => true }
      else
        format.json { render :json => { :message => newsletter_signup.errors }, :status => 400 }
      end
    end
  end
end
