class UsersController < ApplicationController
  skip_filter :logged_in?	

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to root_url
    end
  end

end