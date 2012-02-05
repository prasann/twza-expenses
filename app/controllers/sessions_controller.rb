# TODO: Should this be merged into the users controller? How is it different?
class SessionsController < ApplicationController
  skip_filter :logged_in?

  def create
    user = User.authenticate(params[:user_name], params[:password])
    if user
      session[:user_id] = user.id
      redirect_to outbound_travels_url
    else
      flash[:error] = "Invalid email or password"
      render 'new'
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url
  end
end
