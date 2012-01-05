class ProfileController < ApplicationController
  def list
    @profiles = Profile.where("name like '#{params[:name]}%'")
    render :json => @profiles
  end
end
