# TODO: This controller should not even be needed - use routes to limit?
class HomeController < ApplicationController
  def index
    redirect_to :controller => 'outbound_travels', :action => 'index'
  end
end
