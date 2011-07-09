class TastingNotesController < ApplicationController
  include ActionView::Helpers::DateHelper

  def create
    @beer = current_user.cellar.beers.find(params[:beer_id])
    @tasting_note = @beer.tasting_notes.create(params[:tasting_note])

    respond_to do |format|
      if @tasting_note.persisted?
        format.html { render :partial => 'list', :locals => { :tasting_note => @tasting_note } }
        format.json { render :json => @tasting_note.to_json }
      else
        format.json { render :json => { :status => :error }, :status => 400 }
      end
    end
  end
end
