module CellarsHelper
  def is_users_cellar?
    return @cellar.user == @user
  end

  def cellar_url
    if full_host.nil?
      return ""
    end

    return "http://" + full_host + "/cellars/" + @cellar.user.username
  end

  def cellar_beers_as_json(cellar)
    cellar.beers.map(&:as_json).map{|b|b['beer']}.to_json
  end
end
