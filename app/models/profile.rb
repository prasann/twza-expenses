class Profile < ActiveRecord::Base
 
  default_scope select("common_name, employee_id")

  def to_special_s
    common_name + '-' + employee_id
  end

  def readonly?
    true
  end

  def before_destroy
    raise ActiveRecord::ReadOnlyRecord
  end
  

end
