class ApplicationController < ActionController::Base
  before_filter :set_cache_buster, :logged_in?
  helper_method :current_user

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  def logged_in?
    if current_user.nil? && ![log_in_url,root_url,sign_up_url,sessions_url].include?(request.url)
      redirect_to log_in_url
    end
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
end