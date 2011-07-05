class SearchController < ApplicationController
  def index
    @results = User.search(params[:q])
  end
end
