class ProfilesController < ApplicationController
  def list
    @profiles = Profile.where("common_name like '#{params[:term]}%'")
    render :text => @profiles.collect(&:to_special_s)
  end
end
