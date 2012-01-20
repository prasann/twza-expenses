class ExpenseReimbursementController < ApplicationController

  def filter
    @expense_reimbursements=[]
    if (!params[:empl_id].blank?)
      @expense_reimbursements=ExpenseReimbursement.where(empl_id: params[:empl_id]).to_a
      expense_ids_from_travel = ExpenseSettlement.where(empl_id: params[:empl_id]).to_a.collect { |settlement| settlement.expenses }.flatten
      reimbursement_expense_ids=[]
      @expense_reimbursements.each do |expense_reimbursement|
        reimbursement_expense_ids.push(expense_reimbursement.expenses.collect { |expense| expense['expense_id'] })
      end
      processed_expense_ids = reimbursement_expense_ids.flatten.push(expense_ids_from_travel).flatten
      unprocessed_expenses = Expense.fetch_for_employee(params[:empl_id], processed_expense_ids).group_by(&:expense_rpt_id)
      unprocessed_expenses.each do |expense_report_id, expenses|
        if (!expenses.empty?)
          @expense_reimbursements.push(ExpenseReimbursement.new(:expense_report_id => expense_report_id,
                                                                :empl_id => params[:empl_id],
                                                                :status => 'Unprocessed',
                                                                :submitted_on=> expenses.first.report_submitted_at,
                                                                :total_amount => expenses.sum { |expense| expense.original_cost.to_f }))
        end
      end
    elsif (!params[:expense_rpt_id].blank?)
      @expense_reimbursements=ExpenseReimbursement.where(expense_report_id: params[:expense_rpt_id]).to_a
      reimbursement_expense_ids=[]
      @expense_reimbursements.each do |expense_reimbursement|
        reimbursement_expense_ids.push(expense_reimbursement.expenses.collect { |expense| expense['expense_id'] })
      end
      unprocessed_expenses = Expense.fetch_for_report(params[:expense_rpt_id], reimbursement_expense_ids.flatten).group_by(&:expense_rpt_id)
      unprocessed_expenses.each do |expense_report_id, expenses|
        if (!expenses.empty?)
          @expense_reimbursements.push(ExpenseReimbursement.new(:expense_report_id => expense_report_id,
                                                                :empl_id => expenses.first.get_employee_id,
                                                                :status => 'Unprocessed',
                                                                :submitted_on=> expenses.first.report_submitted_at,
                                                                :total_amount => expenses.sum { |expense| expense.original_cost.to_f }))
        end
      end

    end
    render 'index'
  end

  def show
    @expense_reimbursement=ExpenseReimbursement.find(params[:id])
    expenses = Expense.find(@expense_reimbursement.expenses.collect { |expense| expense['expense_id'] })
    @all_expenses = expenses.group_by { |expense| expense.project + expense.subproject }
  end

  def edit
    expenses = Expense.where(expense_rpt_id: params[:id]).to_a
    @all_expenses = expenses.group_by { |expense| expense.project + expense.subproject }
    @expense_reimbursement = {'expense_report_id' => params[:id],
                              'empl_id' => expenses.first.get_employee_id,
                              'submitted_on' => expenses.first.report_submitted_at,
                              'total_amount' => expenses.sum { |expense| expense.original_cost.to_f }}

  end

  def process_reimbursement
    expense_ids = params[:selected_expenses]
    expense_amount = params[:expense_amount]
    total_amount = 0
    expenses = []

    expense_ids.each do |expense_id|
      modified_amount=expense_amount[expense_id].to_f
      expenses.push({'expense_id' => expense_id, 'modified_amount' => modified_amount})
      total_amount+=modified_amount
    end
    status = params[:process_reimbursement] ? 'Processed' : 'Faulty'
    @expense_reimbursement = ExpenseReimbursement.new(:expense_report_id => params[:expense_report_id], :expenses => expenses,
                                                      :empl_id => params[:empl_id], :status=> status,
                                                      :submitted_on=> params[:submitted_on], :notes=> params[:notes],
                                                      :total_amount => total_amount)
    @expense_reimbursement.save
    redirect_to :action => 'filter', :empl_id => params[:empl_id]
  end


end
