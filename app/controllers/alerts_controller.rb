class AlertsController < ApplicationController
  def dismiss
    raise session.inspect
    alert = self.current_user.alerts.select{|a| a.name == params[:name]}.first

    if alert.nil?
      current_user.alerts << Alert.new(:name => name, :dismissed => true)
    else
      alert.dismissed = true
    end

    # Done!
    alert.save!

    respond_to do |format|
      format.json { render :nothing => true }
    end
  end
end
