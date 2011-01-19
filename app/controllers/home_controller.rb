class HomeController < ApplicationController
  
  def index
    unless @user.nil?
      @cellar = Cellar.find_by_user(@user)
      @new_beer = Beer.new(:cellar => @cellar)
      
      render :template => 'cellars/show'
    end
  end
  
end
