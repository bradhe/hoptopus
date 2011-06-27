require 'array'

class HomeController < ApplicationController
  def index
    unless @user.nil?
      if current_user.nil? or current_user.should_show_own_events
        @recent_events = Event.order('created_at DESC').limit(15).all
      else 
        @recent_events = Event.order('created_at DESC').limit(15).where('user_id != ?', current_user.id).all
      end

      @newest_cellars = Cellar.newest.first(25).distribute(5)
      @largest_cellars = Cellar.largest.first(25).distribute(5)

      render :template => 'cellars/index'
    end
  end
end
