class Profile < ActiveRecord::Base
  default_scope select("common_name, employee_id, email_id, name, surname")

  validates_presence_of :name, :employee_id, :email_id, :common_name, :allow_blank => false

  def get_full_name
    "#{name} #{surname}".strip.titleize
  end

  def readonly?
    true
  end

  def destroy
    raise ActiveRecord::ReadOnlyRecord
  end
end
