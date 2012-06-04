class EmployeeDetail
	include Mongoid::Document
	field :emp_id, type: String
	field :emp_name, type: String
	field :email, type: String

	validates_presence_of :emp_id, :emp_name, :email, :allow_blank => false
	validates_uniqueness_of :emp_id,:email
end