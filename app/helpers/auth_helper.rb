require 'rubygems'
require 'carmen'

module AuthHelper
  def countries_list
    Carmen.countries
  end
end
