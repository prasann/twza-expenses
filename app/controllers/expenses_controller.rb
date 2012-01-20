class ExpensesController < ApplicationController

  def index
    if (params[:id])
      @expenses = Expense.where(empl_id: params[:id])
    elsif (params[:report_id])
      @expenses = Expense.where(expense_rpt_id: params[:report_id])
    end
  end

end
