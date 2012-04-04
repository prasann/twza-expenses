class ExpenseReimbursementsController < ApplicationController

  def index
    @expense_reimbursements = []
    if !params[:empl_id].blank?
      empl_id = params[:empl_id].to_i
      @expense_reimbursements = ExpenseReimbursement.find_for_empl_id(empl_id)
      expenses_criteria = Expense.for_empl_id(empl_id)
    elsif !params[:expense_rpt_id].blank?
      @expense_reimbursements = ExpenseReimbursement.find_for_expense_report_id(params[:expense_rpt_id])
      expenses_criteria = Expense.for_expense_report_id(params[:expense_rpt_id].to_i)
      empl_id = expenses_criteria.first.try(:empl_id)
    end

    if !empl_id.blank?
      # Find all travel and non-travel expenses processed or under process for empl id
      processed_expense_ids_from_travel = ExpenseSettlement.find_expense_ids_for_empl_id(empl_id)
      reimbursement_expense_ids = @expense_reimbursements.collect(&:expenses).compact

      processed_expense_hashes = reimbursement_expense_ids.push(processed_expense_ids_from_travel).flatten.compact
      processed_expense_ids = processed_expense_hashes.collect{|expense_hash| expense_hash['expense_id']}

      unprocessed_expenses_map = Expense.fetch_for_grouped_by_report_id(expenses_criteria, processed_expense_ids)
      create_unprocessed_expense_reports(empl_id, unprocessed_expenses_map)
    end

    # TODO: This is missing for all index/search/filter actions - ie scenario where no items are found
    flash[:error] = "No expense reimbursements found for given criteria." if @expense_reimbursements.empty? && has_param_keys?(params)
    render 'index', :layout => 'tabs'
  end

  def show
    @expense_reimbursement = ExpenseReimbursement.find(params[:id])
    profile = @expense_reimbursement.profile
    @empl_name = profile.try(:get_full_name) || ""
    @all_expenses = @expense_reimbursement.get_expenses_grouped_by_project_code
  end

  def edit
    expenses = Expense.for_expense_report_id(params[:id].to_i).to_a

    existing_expense_reimbursements = ExpenseReimbursement.find_for_expense_report_id(params[:id])
    # TODO: Performance: Can we move this filter logic into the db?
    if existing_expense_reimbursements.present? && !existing_expense_reimbursements.empty?
      expenses = expenses - existing_expense_reimbursements.collect(&:get_expenses).flatten
    end
    @all_expenses = expenses.group_by(&:project_subproject)

    @empl_name = expenses.first.try(:profile).try(:get_full_name) || ""

    # TODO: Should this be an ExpenseReimbursement so that we can do method calls instead of hash-like access?
    @expense_reimbursement = {'expense_report_id' => params[:id],
      'empl_id' => expenses.first.try(:get_employee_id),
      'submitted_on' => expenses.first.try(:report_submitted_at),
      'total_amount' => expenses.collect(&:cost_in_home_currency).compact.sum.to_f}
  end

  def process_reimbursement
    expense_ids = params[:selected_expenses]
    expense_amount = params[:expense_amount]
    total_amount = 0
    expenses = []

    # TODO: Is 'expense_map' even being used?
    expense_map = Hash.new
    Expense.for_expense_report_id(params[:expense_report_id]).to_a.map { |expense| expense_map[expense.id.to_s] = expense }

    expense_ids.each do |expense_id|
      modified_amount = expense_amount[expense_id].to_f
      expenses.push({'expense_id' => expense_id, 'modified_amount' => modified_amount})
      total_amount += modified_amount
    end
    status = !params[:process_reimbursement].blank? ? ExpenseReimbursement::PROCESSED : ExpenseReimbursement::FAULTY
    @expense_reimbursement = ExpenseReimbursement.new({:expenses => expenses,
                                                       :status => status,
                                                       :total_amount => total_amount}.merge(
                                                          params.slice(:expense_report_id, :empl_id, :submitted_on, :notes)))
    if @expense_reimbursement.save
      redirect_to(expense_reimbursements_path(params.slice(:empl_id)), :flash => {:success => 'Expense reimbursements are successfully updated.'})
    else
      render :action => "edit"
    end
  end

  private
  def create_unprocessed_expense_reports(empl_id, unprocessed_expenses)
    unprocessed_expenses.each do |expense_report_id, expenses|
      @expense_reimbursements.push(ExpenseReimbursement.new(:expense_report_id => expense_report_id,
                                                            :empl_id => empl_id,
                                                            :submitted_on => expenses.first.report_submitted_at,
                                                            :total_amount => expenses.collect(&:cost_in_home_currency).compact.sum.to_f)) if !expenses.empty?
    end
  end

  def has_param_keys?(params)
    return params.has_key?(:empl_id) || params.has_key?(:expense_rpt_id) || params.has_key?(:name)
  end
end
