class ProfilesController < ApplicationController
  def search_by_name
    @profiles = Profile.where("name like '#{params[:term]}%'")
    render :text => @profiles.collect(&:to_special_s)
  end

  def search_by_id
    @profiles = Profile.where("employee_id like '#{params[:term]}%'")
    render :text => @profiles.collect(&:to_special_s)
  end
end
