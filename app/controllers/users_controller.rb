class UsersController < ApplicationController
  def update
    @user = User.find(params[:id])
    
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
  end

  def select_username
    # If this isn't an oauth client then we need to tell them
    # to fuck right off.
    if @user.facebook_id.nil?
      render :status => 404
      return
    end

    @email_address = @user.email
  end

  def update_username
    # See above.
    if @user.facebook_id.nil?
      render :status => 404
      return
    end

    @username = params[:username]

    # just see if the username is now valid.
    @user.username = @username
    
    respond_to do |format|
      if @user.valid?
        # We got three of them! Sweet!
        @user.save!

        format.html { redirect_to root_path }
      else
        # Clear this to prevent some strange behavior.
        @user.username = nil

        # fml
        format.html { render :action => 'select_username' }
      end
    end
  end
end
