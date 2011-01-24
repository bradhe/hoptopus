class HomeController < ApplicationController
  
  def index
    unless @user.nil?
			if @user.should_show_own_events
				@recent_events = Event.order('created_at DESC').limit(15).all
			else 
				@recent_events = Event.order('created_at DESC').limit(15).where("user_id != #{@user.id}").all
			end
    
      @cellars = Cellar.all

      render :template => 'cellars/index'
    end
  end
  
end
