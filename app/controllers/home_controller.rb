require 'array'

class HomeController < ApplicationController
  def index
    unless @user.nil?
      redirect_to dashboard_path
    end
  end

  def tour
  end

  def dashboard
  end
end
