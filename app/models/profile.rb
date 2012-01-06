class Profile < ActiveRecord::Base
  
  def to_json
    {:id => employee_id, :name => name}
  end

  def as_json(*args)
    to_json
  end
end
