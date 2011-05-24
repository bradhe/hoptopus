require 'array'

class HomeController < ApplicationController
  
  def index
    unless @user.nil?
      if @user.nil? or @user.should_show_own_events
        @recent_events = Event.order('created_at DESC').limit(15).all
      else 
        @recent_events = Event.order('created_at DESC').limit(15).where("user_id != ?", @user.id).all
      end

      @newest_cellars = Cellar.order('created_at DESC').limit(25).all.distribute 5
      @largest_cellars = Cellar.all.sort!{ |a,b| b.beers.count <=> a.beers.count }.first(25).distribute 5

      render :template => 'cellars/index'
    end
  end
  
end
