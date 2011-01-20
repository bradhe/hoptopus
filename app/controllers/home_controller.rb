class HomeController < ApplicationController
  
  def index
    unless @user.nil?
      @cellar = Cellar.find_by_user(@user)
      @tastings = @user.tastings
	  
      render :template => 'cellars/show'
    end
  end
  
end