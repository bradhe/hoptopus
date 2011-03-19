class AdminController < ApplicationController
  before_filter :ensure_login, :ensure_user_is_admin
  
  def lobby
    
  end
  
  def ensure_user_is_admin
    if not @user.is_admin?
      render :status => 404
    end
  end
end
