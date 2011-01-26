class CommentsController < ApplicationController
  def create
    if params[:beer_id]
      # Comment is for a beer
    elsif params[:cellar_id]
      # Comment is for a cellar
      cellar = Cellar.find(params[:cellar_id])
      comment = cellar.comments.new params[:comment]
      comment.user = @user # Mark as the current user, of course
      
      if comment.save
        # Send an email if it's warranted
        if cellar.user.should_receive_email_notifications
          Notifications.cellar_comment(cellar, comment).deliver
        end
        
        redirect_to cellar_path(cellar.user.username)
      else
        redirect_to cellar_path(cellar.user.username), :notice => "Hmmm, looks like you're trying to leave a blank comment. That sucks man, why would you do that?"
      end
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
