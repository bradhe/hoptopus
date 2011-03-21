class Admin::UsersController < AdminController
  def index
    @users = User.order('username').all
  end
  
  def makeadmin
    selected_users = params[:selectedUsers].as_json
    
    respond_to do |format|
      format.json { render :nothing => true }
    end
  end
  
end