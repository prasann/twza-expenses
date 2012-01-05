class ExpenseReport
	include Mongoid::Document

	field :expenses, type: Array
	field :forex_payments, type: Array
	field :empl_id, type: String
	field :travel_id, type: String 
end
