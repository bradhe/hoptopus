class CommentsController < ApplicationController
  def create
    if params[:beer_id]
      # Comment is for a beer
    elsif params[:cellar_id]
      # Comment is for a cellar
      cellar = Cellar.find(params[:cellar_id])
      comment = cellar.comments.new params[:comment]
      comment.user = @user # Mark as the current user, of course
      comment.save
      
      redirect_to cellar_path(cellar.user.username)
    elsif params[:tasting_id]
      # Comment is for a tasting.
      tasting = Tasting.find(params[:tasting_id])
      comment = tasting.comments.new params[:comment]
      comment.save
      
      redirect_to brew_tasting_path tasting
    elsif params[:brew_id]
      # Comment is for a brew
    end
  end

  def update
  end

  def destroy
  end

end
