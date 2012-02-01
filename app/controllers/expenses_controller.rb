class ExpensesController < ApplicationController
  # TODO: Which view is handling this action?
  def index
    if params[:id]
      # TODO: These are not being evaluated - but are used in the view as is?
      @expenses = Expense.for_empl_id(params[:id])
    elsif (params[:report_id])
      # TODO: These are not being evaluated - but are used in the view as is?
      @expenses = Expense.for_expense_report_id(params[:report_id])
    end
  end
end
