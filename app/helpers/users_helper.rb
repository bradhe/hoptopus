module UsersHelper
  def listing_link_text(user)
    if(user.full_name)
      "#{user.username} (#{user.full_name})"
    else
      user.username
    end
  end
end
