class AlertsController < ApplicationController
  def dismiss
    name = params[:name]

    alert = Alert.where('name = ? AND user_id = ?', name, @user.id).first

    if alert.nil?
      a = Alert.create(:name => name, :user_id => @user.id)
      a.dismissed = true
      a.save!
    else
      alert.dismissed = true
      alert.save!
    end

    respond_to do |format|
      format.json { render :nothing => true }
    end
  end
end
