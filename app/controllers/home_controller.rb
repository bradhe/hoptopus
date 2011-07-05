class HomeController < ApplicationController
  def index
    unless @user.nil?
      redirect_to dashboard_path
    end
  end

  def tour
  end

  def dashboard
    @recent_events = Event.where(:user => current_user).recent

    # TODO: Add watches here
    #@recent_events = Event.where(:user => current_user).recent
  end
end
