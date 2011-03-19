class Admin::UsersController < AdminController
  def index
    @users = User.order('username').all
  end
end