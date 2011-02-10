class ContactController < ApplicationController
  def index
    @contact_request = ContactRequest.new
  end

  def create
    @contact_request = ContactRequest.new params[:contact_request]
    
    respond_to do |format|
      if @contact_request.valid?
        # Send an email...
        Notifications.contact_request(@contact_request).deliver
        
        # ...and get outta here.
        format.html { redirect_to(contact_request_sent_path) }
      else
        format.html { render :action => 'index' }
      end
    end
  end

  def sent
  end

end
