class ExpenseSettlementsController < ApplicationController
  FOREX_PAYMENT_DATES_PADDED_BY=15
  EXPENSE_DATES_PADDED_BY=5

  def index
    criteria = !params[:empl_id].blank? ? ExpenseSettlement.for_empl_id(params[:empl_id]) : ExpenseSettlement
    # TODO: These are not being evaluated - but are used in the view as is?
    @expense_settlements = criteria.page(params[:page]).per(default_per_page)
  end

  def load_by_travel
    travel = OutboundTravel.find(params[:id])
    padded_dates(travel)
    create_settlement_report_from_dates(travel)
  end

  def edit
    settlement_from_db = ExpenseSettlement.load_with_deps(params[:id])
    @expenses_from_date = DateHelper.date_from_str(settlement_from_db.expense_from)
    @expenses_to_date = DateHelper.date_from_str(settlement_from_db.expense_to)
    @forex_from_date = DateHelper.date_from_str(settlement_from_db.forex_from)
    @forex_to_date = DateHelper.date_from_str(settlement_from_db.forex_to)
    travel = OutboundTravel.find(settlement_from_db.outbound_travel_id)
    create_settlement_report_from_dates(travel, settlement_from_db)
    render 'load_by_travel'
  end

  def show
    @expense_report = ExpenseSettlement.find(params[:id])
    @expense_report.populate_instance_data
    render 'generate_report'
  end

  def generate_report
    expense_settlement = params[:expense_settlement]
    outbound_travel = OutboundTravel.find(expense_settlement[:outbound_travel_id])
    @expense_report = outbound_travel.find_or_initialize_expense_settlement
    @expense_report.update_attributes({:cash_handovers => expense_settlement[:cash_handovers_attributes],
                                       :status => ExpenseSettlement::GENERATED_DRAFT,
                                       :empl_id => expense_settlement[:empl_id],
                                       :emp_name => expense_settlement[:emp_name]}.merge(
                                          params.slice(:expenses, :forex_payments,:expense_from,
                                                       :expense_to, :forex_from, :forex_to).symbolize_keys)
                                       )
    @expense_report.cash_handovers.map(&:save!)
    @expense_report.populate_instance_data
  end

  def set_processed
    expense_report = ExpenseSettlement.find(params[:id])
    # TODO: What if the save failed?
    expense_report.complete
    redirect_to outbound_travels_path
  end

  def notify
    expense_report = ExpenseSettlement.find(params[:id])
    expense_report.notify_employee
    # TODO: What if the save failed?
    # TODO: In the "Rails 3.1" way, flash should be part of the redirect (options hash) - so need to make sure that this actually works
    flash[:success] = "Expense settlement e-mail successfully sent to '#{expense_report.profile.common_name}'"
    redirect_to(:action => :index, :anchor => 'expense_settlements', :empl_id => expense_report.empl_id)
  end

  def show_uploads
    @uploaded_files = UploadedExpense.desc(:created_at)
  end

  def file_upload
    require 'fileutils'
    @file_name = params[:file_upload][:my_file].original_filename
    if load_to_db
      # TODO: In the "Rails 3.1" way, flash should be part of the redirect (options hash) - so need to make sure that this actually works
      flash[:success] = "File: '#{@file_name}' has been uploaded successfully"
    else
      # TODO: In the "Rails 3.1" way, flash should be part of the redirect (options hash) - so need to make sure that this actually works
      flash[:error] = 'This file has already been uploaded'
    end
    redirect_to :action => 'show_uploads'
  end

  private
  def load_to_db
    tmp = params[:file_upload][:my_file].tempfile
    file = File.join("public", @file_name)
    FileUtils.cp(tmp.path, file)
    success = ExpenseReportImporter.new.load_expense(file)
    FileUtils.rm(file)
    success
  end

  def padded_dates(travel)
    @expenses_from_date = !params[:expense_from].blank? ? DateHelper.date_from_str(params[:expense_from]) : travel.departure_date - EXPENSE_DATES_PADDED_BY
    @expenses_to_date = !params[:expense_to].blank? ? DateHelper.date_from_str(params[:expense_to]) : (travel.return_date ? (travel.return_date + EXPENSE_DATES_PADDED_BY) : nil)
    @forex_from_date = !params[:forex_from].blank? ? DateHelper.date_from_str(params[:forex_from]) : travel.departure_date - FOREX_PAYMENT_DATES_PADDED_BY
    @forex_to_date = !params[:forex_to].blank? ? DateHelper.date_from_str(params[:forex_to]) : travel.return_date
  end

  def create_settlement_report_from_dates(travel,expense_settlement=nil)
    # TODO: Is this an ARel call?
    processed_expenses = ExpenseSettlement.load_processed_for(travel.emp_id)
   processed_expense_ids = processed_expenses.collect(&:expenses).flatten
    processed_forex_ids = processed_expenses.collect(&:forex_payments).flatten

    @expenses = Expense.fetch_for_employee_between_dates travel.emp_id, @expenses_from_date, @expenses_to_date, processed_expense_ids
    @forex_payments = ForexPayment.fetch_for travel.emp_id, @forex_from_date, @forex_to_date, processed_forex_ids
    @applicable_currencies = ForexPayment.get_json_to_populate('currency')['currency']
    @expense_report = expense_settlement || ExpenseSettlement.new(:empl_id => travel.emp_id,
                                                                  :outbound_travel_id => travel.id.to_s,
                                                                  :forex_payments => @forex_payments.collect(&:id),
                                                                  :expenses => @expenses.collect(&:id),
                                                                  :cash_handovers => [CashHandover.new])
  end
end
