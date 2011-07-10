class WatchesController < ApplicationController
  def show
    @user = User.find_by_username(params[:cellar_id])
    @watches = @user.watches
  end

  def create
    u = User.find_by_username(params[:user_id])

    unless u and current_user.watching? u
      current_user.watches << u
      create_watched_event(u)
    end

    # Keep jquery from assploding.
    render :json => { :success => true }
  end

  def destroy
    u = User.find_by_username(params[:id])

    if u
      current_user.watches.delete(u)
      render :json => { :success => true }
    else
      render :json => { :success => false}, :status => :not_found
    end
  end

  private
  def create_watched_event(u)
    if e = Event.where(:user_id => current_user.id, :source_id => u, :source_type => User).first
      # Update event to now.
      e.update_attribute(:created_at, Time.now)
    else
      Event.create(:user => current_user, :source => u, :formatter => WatchedEventFormatter)

      if current_user.receive_emails?
        # Send a notification too.
        Notifications.watched(current_user, u).deliver
      end
    end
  end
end
