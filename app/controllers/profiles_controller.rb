class ProfilesController < ApplicationController
  def search_by_name
	employee_details = EmployeeDetail.where(:emp_name => /#{params[:term]}/i)
    render :json => employee_details.to_json(:root => false, :only => [:emp_name, :emp_id])
  end

  def search_by_id
  	employee_details = EmployeeDetail.where(:emp_id => /#{params[:term]}/i).to_a
    render :json => employee_details.to_json(:root => false, :only => [:emp_name, :emp_id])
  end
end