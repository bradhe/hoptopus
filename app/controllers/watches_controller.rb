class WatchesController < ApplicationController
  def show
    @user = User.find_by_username(params[:cellar_id])
    @watches = @user.watches
  end

  def create
    u = User.find_by_username(params[:user_id])
    current_user.watches << u if u

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
end
