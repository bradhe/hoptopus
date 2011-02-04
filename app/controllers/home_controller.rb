class HomeController < ApplicationController
  
  def index
    unless @user.nil?
      if @user.nil? or @user.should_show_own_events
        @recent_events = Event.order('created_at DESC').limit(15).all
      else 
        @recent_events = Event.order('created_at DESC').limit(15).where("user_id != ?", @user.id).all
      end
      
      @oldest_cellars = Cellar.order('created_at ASC').all.distribute 5
      @newest_cellars = Cellar.order('created_at DESC').all.distribute 5
      @largest_cellars = Cellar.all.sort!{ |a,b| b.beers.count <=> a.beers.count }.distribute 5

      render :template => 'cellars/index'
    end
  end
  
end
