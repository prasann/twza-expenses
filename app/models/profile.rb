class Profile < ActiveRecord::Base
 
  default_scope select("common_name, employee_id, email_id, name, surname")

  def to_special_s
    common_name + '-' + employee_id
  end

  def readonly?
    true
  end

  def get_full_name
    name.camelize + ' ' +surname.camelize
  end

  def before_destroy
    raise ActiveRecord::ReadOnlyRecord
  end
  

end
