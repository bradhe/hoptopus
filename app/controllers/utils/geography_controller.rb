class Utils::GeographyController < ActionController::Base
  def states
    begin
    states = Carmen::states(params[:country])

    rescue Carmen::StatesNotSupported
      states = []
    end

    respond_to { |format| format.json { render :json => states.to_json } }
  end
end