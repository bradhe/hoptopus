class WikiController < ApplicationController
  def index
    populate_recent_results
  end

  def list
    type = params['type']
    id = params[:p] || params[:id]

    where_clause = 'lower(name) LIKE ?'

    # Some special cases for query parameters
    q = nil
    
    if id == 'num'
      where_clause = (0..9).map { 'lower(name) LIKE ?' }.join(' OR ')
      q = (0..9).map { |i| "#{i}%" }
    elsif id == 'sym'
      arr = ".,#".split(//)
      where_clause = arr.map { 'lower(name) LIKE ?' }.join(' OR ')
      q = arr.map { |i| "#{i}%" }
    elsif id and id.length > 1
      q = ["#{id[0]}%"]
    else
      q = ["#{id}%"]
    end

    if type == "brews"
      @brews = Brew.where(where_clause, *q).all if q
      render :template => "wiki/list_brews"
    elsif type == "breweries"
      @breweries = Brewery.where(where_clause, *q).all if q
      render :template => "wiki/list_breweries"
    elsif type
      raise NotImplementedError "No template for type #{type} was not found"
    else
      raise RangeError "No type was specified."
    end
  end

  def populate_recent_results
    @recent_events = Event.where('source_type = ? OR source_type = ?', 'Brew', 'Tasting').order('created_at DESC').limit(15).all
  end
end
