# TODO: Shouldn't this be merged with the sessions_controller?
class UsersController < ApplicationController
  skip_filter :logged_in?

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to(root_path)
    else
      render :action => 'new'
    end
  end

  private
  def user_params
    params.require(:user).permit(:user_name, :password, :password_confirmation)
  end
end
