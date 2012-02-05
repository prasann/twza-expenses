class ExpenseReimbursementsController < ApplicationController
  def index
    render :layout => 'tabs'
  end

  # TODO: In the REST world, filter is equivalent to index - just adding some extra query strings that are used to filter by
  def filter
    @expense_reimbursements = []
    if !params[:empl_id].blank?
      empl_id = params[:empl_id]
      @expense_reimbursements = ExpenseReimbursement.for_empl_id(empl_id).to_a
      expenses_criteria = Expense.for_employee_id(empl_id)
    elsif !params[:expense_rpt_id].blank?
      @expense_reimbursements = ExpenseReimbursement.for_expense_report_id(params[:expense_rpt_id]).to_a
      expenses_criteria = Expense.for_expense_report_id(params[:expense_rpt_id])
      expense = expenses_criteria.first
      empl_id = expense.nil? ? nil : expense.get_employee_id
    end

    if !empl_id.blank?
      # TODO: This whole block should move into a model/manager
      expense_ids_from_travel = ExpenseSettlement.for_empl_id(empl_id).to_a.collect(&:expenses).flatten
      reimbursement_expense_ids = []
      # TODO: Is this inject([])?
      @expense_reimbursements.each do |expense_reimbursement|
        # TODO: Encapsulation?
        reimbursement_expense_ids.push(expense_reimbursement.expenses.collect { |expense| expense['expense_id'] })
      end

      processed_expense_ids = reimbursement_expense_ids.push(expense_ids_from_travel).flatten

      unprocessed_expenses_map = Expense.fetch_for(expenses_criteria, processed_expense_ids).group_by(&:expense_rpt_id)
      create_unprocessed_expense_reports(empl_id, unprocessed_expenses_map)
    end

    render 'index', :layout => 'tabs'
  end

  def show
    @expense_reimbursement = ExpenseReimbursement.find(params[:id])
    profile = @expense_reimbursement.profile
    @empl_name = profile.try(:get_full_name) || ""
    @all_expenses = @expense_reimbursement.get_expenses_grouped_by_project_code
  end

  def edit
    expenses = Expense.for_expense_report_id(params[:id]).to_a

    @empl_name = expenses.first.try(:profile).try(:get_full_name) || ""

    existing_expense_reimbursements = ExpenseReimbursement.for_expense_report_id(params[:id]).to_a

    # TODO: Performance: Can we move this filter logic into the db?
    if existing_expense_reimbursements.present? && !existing_expense_reimbursements.empty?
      expenses = expenses - existing_expense_reimbursements.collect(&:get_expenses).flatten
    end
    @all_expenses = expenses.group_by { |expense| expense.project + expense.subproject }

    # TODO: Should this be an OpenStruct so that we can do method calls instead of hash-like access?
    @expense_reimbursement = {'expense_report_id' => params[:id],
                              'empl_id' => expenses.first.try(:get_employee_id),
                              'submitted_on' => expenses.first.try(:report_submitted_at),
                              'total_amount' => expenses.sum { |expense| expense.cost_in_home_currency.to_f }}
  end

  def process_reimbursement
    expense_ids = params[:selected_expenses]
    expense_amount = params[:expense_amount]
    total_amount = 0
    expenses = []

    expense_map = Hash.new
    Expense.for_expense_report_id(params[:expense_report_id]).to_a.map { |expense| expense_map[expense.id.to_s] = expense }
    expense_ids.each do |expense_id|
      modified_amount = expense_amount[expense_id].to_f
      expenses.push({'expense_id' => expense_id, 'modified_amount' => modified_amount})
      total_amount += modified_amount
    end
    status = params[:process_reimbursement] ? 'Processed' : 'Faulty'
    @expense_reimbursement = ExpenseReimbursement.create(:expense_report_id => params[:expense_report_id],
                                                         :empl_id => params[:empl_id],
                                                         :submitted_on => params[:submitted_on],
                                                         :notes => params[:notes],
                                                         :expenses => expenses,
                                                         :status => status,
                                                         :total_amount => total_amount)
    # TODO: This be moved to the after_create hook on expense_reimbursement
    EmployeeMailer.non_travel_expense_reimbursement(@expense_reimbursement).deliver
    redirect_to :action => 'filter', :empl_id => params[:empl_id]
  end

  private
  def create_unprocessed_expense_reports(empl_id, unprocessed_expenses)
    unprocessed_expenses.each do |expense_report_id, expenses|
      @expense_reimbursements.push(ExpenseReimbursement.new(:expense_report_id => expense_report_id,
                                                            :empl_id => empl_id,
                                                            :status => 'Unprocessed',
                                                            :submitted_on => expenses.first.report_submitted_at,
                                                            :total_amount => expenses.sum { |expense| expense.cost_in_home_currency.to_f })) if !expenses.empty?
    end
  end
end
