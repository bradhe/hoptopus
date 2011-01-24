class HomeController < ApplicationController
  
  def index
    unless @user.nil?
      @recent_events = Event.order('created_at DESC').limit(15).where("user_id != #{@user.id}").all
      @cellars = Cellar.all

      render :template => 'cellars/index'
    end
  end
  
end
