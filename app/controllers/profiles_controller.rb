class ProfilesController < ApplicationController
  def search_by_name
    @profiles = Profile.where("common_name like ?", "%#{params[:term]}%").order(:common_name)
    render :json => @profiles.to_json(:root => false, :only => [:employee_id, :common_name])
  end

  def search_by_id
    @profiles = Profile.where("employee_id like ?", "%#{params[:term]}%").order(:employee_id)
    render :json => @profiles.to_json(:root => false, :only => [:employee_id, :common_name])
  end
end
