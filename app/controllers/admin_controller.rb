class AdminController < ApplicationController
  before_filter :ensure_user_is_admin
  
  def lobby
    
  end
  
  def ensure_user_is_admin
    unless @user and @user.is_admin?
      render_404
    end
  end
end