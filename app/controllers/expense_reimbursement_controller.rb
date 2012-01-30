class ExpenseReimbursementController < ApplicationController

  def index
    render :layout => 'tabs'
  end

  def collect_reimbursement_expense_ids
    reimbursement_expense_ids=[]
    @expense_reimbursements.each do |expense_reimbursement|
      reimbursement_expense_ids.push(expense_reimbursement.expenses.collect { |expense| expense['expense_id'] })
    end
    reimbursement_expense_ids
  end

  def create_unprocessed_expense_reports(empl_id, unprocessed_expenses)
    unprocessed_expenses.each do |expense_report_id, expenses|
      if (!expenses.empty?)
        @expense_reimbursements.push(ExpenseReimbursement.new(:expense_report_id => expense_report_id,
                                                              :empl_id => empl_id,
                                                              :status => 'Unprocessed',
                                                              :submitted_on=> expenses.first.report_submitted_at,
                                                              :total_amount => expenses.sum { |expense| expense.cost_in_home_currency.to_f }))
      end
    end
  end

  def filter
    @expense_reimbursements=[]
    if (!params[:empl_id].blank?)
      empl_id=params[:empl_id]
      @expense_reimbursements = ExpenseReimbursement.where(empl_id: empl_id).to_a
      expense_ids_from_travel = ExpenseSettlement.where(empl_id: empl_id).to_a.collect { |settlement| settlement.expenses }.flatten
      reimbursement_expense_ids = collect_reimbursement_expense_ids()
      processed_expense_ids = reimbursement_expense_ids.flatten.push(expense_ids_from_travel).flatten
      unprocessed_expenses = Expense.fetch_for_employee(empl_id, processed_expense_ids).group_by(&:expense_rpt_id)
      create_unprocessed_expense_reports(empl_id, unprocessed_expenses)
    elsif (!params[:expense_rpt_id].blank?)
      @expense_reimbursements=ExpenseReimbursement.where(expense_report_id: params[:expense_rpt_id]).to_a
      reimbursement_expense_ids = collect_reimbursement_expense_ids()
      unprocessed_expenses_map = Expense.fetch_for_report(params[:expense_rpt_id], reimbursement_expense_ids.flatten).group_by(&:expense_rpt_id)
	  unprocessed_expenses = unprocessed_expenses_map[params[:expense_rpt_id]]
      empl_id = @expense_reimbursements.empty? ? (unprocessed_expenses.nil? ? unprocessed_expenses.first.get_employee_id : "") : @expense_reimbursements.first.get_employee_id
      create_unprocessed_expense_reports(empl_id, unprocessed_expenses_map)
    end
    render 'index', :layout => 'tabs'
  end

  def show
    @expense_reimbursement=ExpenseReimbursement.find(params[:id])
    @empl_name = Profile.find_by_employee_id(@expense_reimbursement.empl_id).get_full_name
    @all_expenses = @expense_reimbursement.get_expenses_grouped_by_project_code
  end

  def edit
    expenses = Expense.where(expense_rpt_id: params[:id]).to_a
    
	employee = Profile.find_by_employee_id(expenses.first.get_employee_id.to_i)
	@empl_name = employee.nil? ? "" : employee.get_full_name
    
	existing_expense_reimbursements = ExpenseReimbursement.where(expense_report_id: params[:id]).to_a
    
	if (existing_expense_reimbursements.empty?)
      @all_expenses = expenses.group_by { |expense| expense.project + expense.subproject }
    else
      expenses = expenses-existing_expense_reimbursements.collect{ |existing_expense_reimbursement| existing_expense_reimbursement.get_expenses }.flatten
      @all_expenses = expenses.group_by { |expense| expense.project + expense.subproject }
    end
    
	@expense_reimbursement = {'expense_report_id' => params[:id],
                              'empl_id' => expenses.first.get_employee_id,
                              'submitted_on' => expenses.first.report_submitted_at,
                              'total_amount' => expenses.sum { |expense| expense.cost_in_home_currency.to_f }}

  end

  def process_reimbursement
    expense_ids = params[:selected_expenses]
    expense_amount = params[:expense_amount]
    total_amount = 0
    expenses = []

    expense_map = Hash.new()
    Expense.fetch_for_report(params[:expense_report_id], []).map { |expense| expense_map[expense.id.to_s] = expense }
    expense_ids.each do |expense_id|
      modified_amount=expense_amount[expense_id].to_f*expense_map[expense_id].cost_in_home_currency.to_f/expense_map[expense_id].original_cost.to_f
      expenses.push({'expense_id' => expense_id, 'modified_amount' => modified_amount})
      total_amount+=modified_amount
    end
    status = params[:process_reimbursement] ? 'Processed' : 'Faulty'
    @expense_reimbursement = ExpenseReimbursement.new(:expense_report_id => params[:expense_report_id], :expenses => expenses,
                                                      :empl_id => params[:empl_id], :status=> status,
                                                      :submitted_on=> params[:submitted_on], :notes=> params[:notes],
                                                      :total_amount => total_amount)
    @expense_reimbursement.save
    profile = Profile.find_by_employee_id(@expense_reimbursement.empl_id)
    EmployeeMailer.non_travel_expense_reimbursement(profile, @expense_reimbursement).deliver
    redirect_to :action => 'filter', :empl_id => params[:empl_id]
  end


end
