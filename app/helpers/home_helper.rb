module HomeHelper
  def recent_watched_events(user)
    Event.where('user_id IN (?)', user.watches.map(&:id)).recent
  end
end
