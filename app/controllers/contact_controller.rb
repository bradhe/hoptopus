class ContactController < ApplicationController
  def index
    @contact_request = ContactRequest.new
  end

  def create
    @contact_request = ContactRequest.new params[:contact_request]
    
    respond_to do |format|
      if @contact_request.valid? and @contact_request.create
        format.html { redirect_to(contact_sent_path, :notice => 'Your contact request has been delivered!') }
      else
        format.html { render :action => 'index' }
      end
    end
  end

  def sent
  end

end
