require 'ostruct'

class ExpenseReimbursement
  include Mongoid::Document
  include Mongoid::Timestamps

  field :expense_report_id, type: Integer
  field :empl_id, type: String
  field :expenses, type: Array
  field :status, type: String
  field :submitted_on, type: Date
  field :total_amount, type: Float
  field :notes, type: String

  	def get_expenses_grouped_by_project_code
    	_expenses = Expense.find(expenses.collect { |expense| expense['expense_id'] })
		_expenses.group_by { |expense| expense.project + expense.subproject }
	end

  	def get_expenses
    	Expense.find(expenses.collect { |expense| expense['expense_id'] })
  	end

	def self.get_reimbursable_expense_reports(mark_as_closed=false)
		completed_reimbursements = ExpenseReimbursement.where(status: 'Processed').to_a
		completed_reimbursements.collect{|reimbursement| create_bank_reimbursement(reimbursement, mark_as_closed)}
	end

	private
	def self.create_bank_reimbursement(reimbursement, mark_as_closed)
		bank_detail = BankDetail.where(empl_id: reimbursement.empl_id).first
		if(mark_as_closed)
			reimbursement.status = 'Closed'
			reimbursement.save
		end
		OpenStruct.new({:empl_id => reimbursement.empl_id,
		 :empl_name => bank_detail.empl_name,
		 :expense_report_ids => reimbursement.expense_report_id,
		 :reimbursable_amount => reimbursement.total_amount,
		 :bank_account_no => bank_detail.account_no
		})
	end
end
