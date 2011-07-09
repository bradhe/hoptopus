class AdminController < ApplicationController
  before_filter :ensure_user_is_admin

  def lobby

  end

  def ensure_user_is_admin
    unless current_user and current_user.admin?
      render_404
    end
  end
end
