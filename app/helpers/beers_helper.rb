module BeersHelper
  def ratable_field_tags(name, initial_value=nil, params={})
    min, max = 1,5
    max = params[:max].to_i if params.has_key? :max
    min = params[:min].to_i if params.has_key? :min

    render 'beers/ratable', :max => max, :min => min, :tag_name => name, :initial_value => initial_value
  end
end
