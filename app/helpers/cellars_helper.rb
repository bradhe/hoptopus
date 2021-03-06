module CellarsHelper
  def is_users_cellar?(cellar)
    return cellar.user == current_user
  end

  def active_beers_as_json(cellar)
    cellar.active_beers.map(&:as_json).map{|b|b['beer']}.to_json
  end

  def favorite_brewery(cellar)
    find_most_popular(cellar.beers.map(&:brewery))
  end

  def favorite_beer(cellar)
    find_most_popular(cellar.beers.map { |b| "#{b.name} (#{b.brewery})"})
  end

  def favorite_style(cellar)
    find_most_popular(cellar.beers.map(&:style))
  end

  def oldest_beer(cellar)
    beer = cellar.beers.reject { |b| b.year.nil? }.sort_by { |b| b.year }.first
    "#{beer.year} #{beer.name} (#{beer.brewery})" if beer
  end

  private
  def find_most_popular(arr)
    return nil if arr.empty?
    arr.inject(Hash.new(0)) {|h,i| h[i] += 1; h }.sort_by { |k,v| v }.last.first
  end
end
