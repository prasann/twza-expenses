class HomeController < ApplicationController
	def index
		redirect_to :controller => 'outbound_travels',:action => 'index'
	end
end