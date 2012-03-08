class Profile < ActiveRecord::Base
  default_scope select("common_name, employee_id, email_id, name, surname")

  validates_presence_of :name, :employee_id, :email_id, :common_name, :allow_blank => false

  def readonly?
    true
  end

  def get_full_name
    surname.nil? ? name.camelize : name.camelize + ' ' + surname.camelize
  end

  def before_destroy
    raise ActiveRecord::ReadOnlyRecord
  end
end
