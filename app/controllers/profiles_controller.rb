class ProfilesController < ApplicationController
  def search_by_name
    # TODO: sanitize param - SQL injection vulnerability
    @profiles = Profile.where("common_name like '#{params[:term]}%'")
    render :json => @profiles.to_json(:root => false, :only => [:employee_id, :common_name])
  end

  def search_by_id
    # TODO: sanitize param - SQL injection vulnerability
    @profiles = Profile.where("employee_id like '#{params[:term]}%'")
    render :json => @profiles.to_json(:root => false, :only => [:employee_id, :common_name])
  end
end
