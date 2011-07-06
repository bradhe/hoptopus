class WatchesController < ApplicationController
  def create
    u = User.find_by_username(params[:user_id])
    current_user.watches << u if u

    # Keep jquery from assploding.
    render :json => { :success => true }
  end

  def destroy
    u = User.find_by_username(params[:user_id])
    current_user.watches.remove(u) if u
  end
end
