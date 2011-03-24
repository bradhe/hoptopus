class Admin::UsersController < AdminController
  def index
    @users = User.order('username').all
  end

  def get_users
    params["values"];
  end

  def makeadmin
    get_users.each { |user_id| User.find(user_id).make_admin }
    respond_to { |format| format.json { render :json => get_users.to_json } }
  end

  def revokeadmin
    get_users.each { |user_id| User.find(user_id).revoke_admin }
    respond_to { |format| format.json { render :json => get_users.to_json } }
  end

  def disableuser
    get_users.each { |user_id| User.find(user_id).disable }
    respond_to { |format| format.json { render :json => get_users.to_json } }
  end

  def deleteuser
    get_users.each { |user_id| User.find(user_id).destroy }
    respond_to { |format| format.json { render :json => get_users.to_json } }
  end
  
end