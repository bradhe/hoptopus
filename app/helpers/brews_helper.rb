module BrewsHelper
  def brew_location(brew)
    location = ''
    
    if brew.nil? or brew.brewery.nil?
      return 'Unknown'
    end
    
    brewery = brew.brewery
    
    if brewery.city and brewery.state and brewery.country
      location = brewery.city + ', ' + brewery.state + ' (' + brewery.country + ')'
    elsif brewery.city and brewery.state
      location = brewery.cirt + ', ' + brewery.state
    elsif brewery.city and brewery.country
      location = brewery.city + ' (' + brewery.country + ')'
    elsif brewery.state and brewery.country
      location = brewery.state + ' (' + brewery.country + ')'
    elsif brewery.city
      location = brewery.city
    elsif brewery.state
      location = brewery.state
    elsif brewery.country
      location = brewery.country
    else
      location = 'Unknown'
    end
    
    return location
  end
end
