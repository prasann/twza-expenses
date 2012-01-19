class ExpenseReimbursement
	include Mongoid::Document
	include Mongoid::Timestamps

	field :expense_report_id, type: Integer
	field :empl_id, type: String
	field :expenses, type: Array
	field :status, type: String
	field :submitted_on, type: Date
	field :total_amount, type: Float
end
