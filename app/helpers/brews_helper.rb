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
  
  def suggested_aging(brew)
    if brew.suggested_aging_years and brew.suggested_aging_months
      return "#{brew.suggested_aging_years} year#{ 's' unless brew.suggested_aging_years == 1} #{brew.suggested_aging_months} month#{ 's' unless brew.suggested_aging_months == 1}"
    elsif brew.suggested_aging_years
      return "#{brew.suggested_aging_years} year#{ 's' unless brew.suggested_aging_years == 1}"
    elsif brew.suggested_aging_months
      return "#{brew.suggested_aging_months} month#{ 's' unless brew.suggested_aging_months == 1}"
    end
    
    'Unknown'
  end
end
