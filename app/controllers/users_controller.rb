class UsersController < ApplicationController
  skip_filter :logged_in?

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    redirect_to root_url if @user.save
  end
end
