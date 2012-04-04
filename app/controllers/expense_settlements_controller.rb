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
    @expenses_from_date = settlement_from_db.expense_from
    @expenses_to_date = settlement_from_db.expense_to
    @forex_from_date = settlement_from_db.forex_from
    @forex_to_date = settlement_from_db.forex_to
    travel = OutboundTravel.find(settlement_from_db.outbound_travel_id)
    create_settlement_report_from_dates(travel, settlement_from_db)
    render 'load_by_travel'
  end

  def show
    @expense_settlement = ExpenseSettlement.find_by_id_with_expenses_and_forex(params[:id])
    render 'generate_report'
  end

  def generate_report
    outbound_travel = OutboundTravel.find(params[:expense_settlement][:outbound_travel_id])
    @expense_settlement = outbound_travel.find_or_initialize_expense_settlement
    @expense_settlement.update_attributes!({:cash_handovers => params[:expense_settlement][:cash_handovers_attributes],
                                           :status => ExpenseSettlement::GENERATED_DRAFT,
                                           :empl_id =>  params[:expense_settlement][:empl_id],
                                           :emp_name => params[:expense_settlement][:emp_name],
                                           :expense_from => DateHelper.date_from_str(params[:expense_from]),
                                           :expense_to => DateHelper.date_from_str(params[:expense_to]),
                                           :forex_from => DateHelper.date_from_str(params[:forex_from]),
                                           :forex_to => DateHelper.date_from_str(params[:forex_to])
                                          }.merge(params.slice(:expenses, :forex_payments).symbolize_keys))
    @expense_settlement.cash_handovers.map(&:save!)
    @expense_settlement.populate_instance_data
  end

  def set_processed
    is_processed = ExpenseSettlement.mark_as_complete(params[:id])

    redirect_to(outbound_travels_path, :flash => get_flash_message(is_processed,
                                                                  "Completed processing Travel settlement",
                                                                  "Failed to complete Travel settlement"))
  end

  def notify
    expense_report = ExpenseSettlement.find_and_notify_employee(params[:id])
    # TODO: What if the save or notify failed?
    redirect_to(expense_settlements_path(:anchor => 'expense_settlements'), :flash => {:success => "Expense settlement e-mail successfully sent to '#{expense_report.profile.try(:common_name)}'"})
  end

  def show_uploads
    @uploaded_files = UploadedExpense.desc(:created_at)
  end

  def delete_cash_handover
    CashHandover.delete_all(conditions: {_id: BSON::ObjectId(params[:id])})
    render :nothing => true, :status => :ok
  end

  def file_upload
    require 'fileutils'
    @file_name = params[:file_upload][:my_file].original_filename
    redirect_to(show_uploads_expense_settlements_path, :flash => get_flash_message(load_to_db,
                                                              "File: '#{@file_name}' has been uploaded successfully",
                                                              'No records uploaded. Either this file has already been uploaded or all rows have errors'))
  end

  private
  def load_to_db
    tmp = params[:file_upload][:my_file].tempfile
    file = File.join("public", @file_name)
    FileUtils.cp(tmp.path, file)
    success = ExpenseImporter.new.load_expense(file)
    FileUtils.rm(file)
    success
  end

  def padded_dates(travel)
    @expenses_from_date = !params[:expense_from].blank? ? DateHelper.date_from_str(params[:expense_from]) : travel.departure_date - EXPENSE_DATES_PADDED_BY
    @expenses_to_date = !params[:expense_to].blank? ? DateHelper.date_from_str(params[:expense_to]) : (travel.return_date ? (travel.return_date + EXPENSE_DATES_PADDED_BY) : nil)
    @forex_from_date = !params[:forex_from].blank? ? DateHelper.date_from_str(params[:forex_from]) : travel.departure_date - FOREX_PAYMENT_DATES_PADDED_BY
    @forex_to_date = !params[:forex_to].blank? ? DateHelper.date_from_str(params[:forex_to]) : travel.return_date
  end

  def create_settlement_report_from_dates(travel, expense_settlement = nil)
    # TODO: Is this an ARel call?
    processed_expenses = ExpenseSettlement.load_processed_for(travel.emp_id)
    processed_expense_hashes = processed_expenses.collect(&:expenses).flatten.compact
    processed_expense_ids = processed_expense_hashes.collect{|expense_hash| expense_hash['expense_id']}

    processed_forex_ids = processed_expenses.collect(&:forex_payments).flatten.compact

    @expenses = Expense.fetch_for_employee_between_dates(travel.emp_id, @expenses_from_date, @expenses_to_date, processed_expense_ids)
    @forex_payments = ForexPayment.fetch_for(travel.emp_id, @forex_from_date, @forex_to_date, processed_forex_ids)
    @applicable_currencies = ForexPayment.get_json_to_populate('currency')['currency']
    @payment_modes = [CashHandover::CASH, CashHandover::CREDIT_CARD]
    @has_cash_handovers = !expense_settlement.nil? && expense_settlement.cash_handovers.size() > 0
    @expense_settlement = expense_settlement || ExpenseSettlement.new(:empl_id => travel.emp_id,
                                                                  :outbound_travel_id => travel.id.to_s,
                                                                  :forex_payments => @forex_payments.collect(&:id),
                                                                  :expenses => @expenses.collect(&:id),
                                                                  :cash_handovers => [CashHandover.new])
  end

  def get_flash_message(flag, success_message, error_message)
    if(flag)
      return {:success => success_message}
    else
      return {:error => error_message}
    end
  end
end
