class ProfilesController < ApplicationController
  def search_by_name
    # TODO: sanitize param - SQL injection vulnerability
    @profiles = Profile.where("common_name like '#{params[:term]}%'")
    render :text => @profiles.collect(&:to_special_s)
  end

  def search_by_id
    # TODO: sanitize param - SQL injection vulnerability
    @profiles = Profile.where("employee_id like '#{params[:term]}%'")
    render :text => @profiles.collect(&:to_special_s)
  end
end
