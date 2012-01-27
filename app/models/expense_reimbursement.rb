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
end
