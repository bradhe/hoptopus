module WikiHelper
  def first_letters_link_list(base_path = '', params = {})
    first_letters = ('A'..'Z').to_a.unshift('#').unshift('!')

    first_letters.each do |i|
      parameter = i

      if i == '#'
        parameter = 'num'
      elsif i == '!'
        parameter = 'sym'
      else
        parameter = parameter.downcase
      end

      uri = URI.parse(request.url)
      uri.query = nil # Clear away any query string params
      
      base_path = uri.path if base_path.empty?

      if base_path.ends_with? "brews" or base_path.ends_with? "breweries"
        uri.path = base_path + "/#{parameter}"
      else
        uri.path = base_path.gsub(/\/[a-z]+$/, '/' + parameter)
      end
      
      link_params = {}
      
      if (params[:q] || params[:id]) == parameter
        link_params[:class] = 'selected'
      end

      if params[:for_javascript]
        link_params = link_params.merge!({ 'data-path' => uri.to_s })
        concat link_to(i, 'javascript:void(0);', link_params)
      else
        concat link_to(i, uri.to_s, link_params)
      end

    end

    # This blocks the weird output.
    nil
  end
end
