class Profile < ActiveRecord::Base
  
  def to_special_s
    name + ' - ' + employee_id
  end

end
