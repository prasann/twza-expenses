class Profile < ActiveRecord::Base
  
  def to_json
    {:id => employee_id, :name => name}
  end
end
