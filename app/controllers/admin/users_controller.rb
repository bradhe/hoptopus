class Admin::UsersController < AdminController
  def index
    @users = User.order('username').all
  end
  
  def makeadmin
    selected_users = params["selected_users"]

    selected_users.each do |user_id|
      User.find(user_id).make_admin
    end

    respond_to do |format|
      format.json { render :json => selected_users.to_json }
    end
  end

  def deleteuser
    
  end

  def revokeadmin
    selected_users = params["selected_users"]

    selected_users.each do |user_id|
      User.find(user_id).revoke_admin
    end

    respond_to do |format|
      format.json { render :json => selected_users.to_json }
    end
  end
  
end