class BankDetail
	include Mongoid::Document

	field :empl_id, type: String
	field :empl_name, type: String
	field :account_no, type: Integer

	validates_presence_of :empl_id, :account_no
end
