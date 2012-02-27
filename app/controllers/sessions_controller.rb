# TODO: Should this be merged into the users controller? How is it different? Usually - we don't expose the mechanism of how the authenticated user is kept alive within the app.
class SessionsController < ApplicationController
  skip_filter :logged_in?

  def new
  end

  def create
    user = User.authenticate(params[:user_name], params[:password])
    if user
      session[:user_id] = user.id
      redirect_to outbound_travels_path
    else
      # TODO: In the "Rails 3.1" way, flash should be part of the redirect (options hash) - so need to make sure that this actually works
      flash[:error] = "Invalid email or password"
      render 'new'
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
end
