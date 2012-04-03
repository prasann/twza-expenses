class ApplicationController < ActionController::Base
  before_filter :set_cache_buster, :logged_in?
  helper_method :current_user, :default_per_page

  layout :resolve_layout

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  def logged_in?
    redirect_to(new_session_path) if current_user.nil?
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def default_per_page
    params[:per_page] || 20
  end

  def resolve_layout
    # list pages go through index if that changes this method should change or method to override layout
    if action_name == "index"
      "tabs"
    else
      "application"
    end
  end
end
