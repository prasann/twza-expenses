class UsersController < ApplicationController
  skip_filter :logged_in?

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    # TODO: What if there is an error?
    redirect_to root_path if @user.save
  end
end
