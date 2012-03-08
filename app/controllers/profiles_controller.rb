class ProfilesController < ApplicationController
  def search_by_name
    # TODO: sanitize param - SQL injection vulnerability
    @profiles = Profile.where("common_name like '#{params[:term]}%'")
    # TODO: Why not pass pure json without special formatting - the current way, the text is split back into individual attributes on the js side
    render :text => @profiles.collect(&:to_special_s)
  end

  def search_by_id
    # TODO: sanitize param - SQL injection vulnerability
    @profiles = Profile.where("employee_id like '#{params[:term]}%'")
    # TODO: Why not pass pure json without special formatting - the current way, the text is split back into individual attributes on the js side
    render :text => @profiles.collect(&:to_special_s)
  end
end
