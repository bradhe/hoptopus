class UsersController < ApplicationController
  def update
    @user = User.find params[:id]

    if @user.id.eql? session[:user_id]

      if(params[:user][:email].blank? and params[:user][:confirm].blank?)
        params[:user].delete :email
        params[:user].delete :email_confirmation
      end

      if params[:user][:state].nil?
        @user.state = nil
      end

      respond_to do |format|
        if @user.update_attributes(params[:user])
          format.html { redirect_to(cellar_path(@user.username), :notice => 'Your preferences have been saved!') }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @tasting.errors, :status => :unprocessable_entity }
        end
      end
    else
      render_404
    end
  end
end
