class ExpenseSettlementsController < ApplicationController
  FOREX_PAYMENT_DATES_PADDED_BY=15
  EXPENSE_DATES_PADDED_BY=5

  def index
    criteria = !params[:empl_id].blank? ? ExpenseSettlement.for_empl_id(params[:empl_id]) : ExpenseSettlement
    # TODO: These are not being evaluated - but are used in the view as is?
    @expense_settlements = criteria.page(params[:page]).per(default_per_page)
  end

  def load_by_travel
    @travel = OutboundTravel.find(params[:id])
    padded_dates(@travel)
    create_settlement_report_from_dates(@travel.emp_id)
  end

  def edit
    settlement_from_db = ExpenseSettlement.load_with_deps(params[:id])
    @expenses_from_date = settlement_from_db.expense_from
    @expenses_to_date = settlement_from_db.expense_to
    @forex_from_date = settlement_from_db.forex_from
    @forex_to_date = settlement_from_db.forex_to
    create_settlement_report_from_dates(settlement_from_db.empl_id.to_i, settlement_from_db)
    render 'load_by_travel'
  end

  def show
    @expense_settlement = ExpenseSettlement.find_by_id_with_expenses_and_forex(params[:id])
    render 'generate_report'
  end

  def generate_report
    @expense_settlement = ExpenseSettlement.find_or_initialize(params[:expense_settlement][:id])
    @expense_settlement.update_attributes!({:cash_handovers => params[:expense_settlement][:cash_handovers_attributes],
                                           :status => ExpenseSettlement::GENERATED_DRAFT,
                                           :empl_id =>  params[:expense_settlement][:empl_id],
                                           :emp_name => params[:expense_settlement][:emp_name],
                                           :expense_from => DateHelper.date_from_str(params[:expense_from]),
                                           :expense_to => DateHelper.date_from_str(params[:expense_to]),
                                           :forex_from => DateHelper.date_from_str(params[:forex_from]),
                                           :forex_to => DateHelper.date_from_str(params[:forex_to]),
                                           :created_by => User.find(session[:user_id]).user_name
                                          }.merge(params.slice(:expenses, :forex_payments).symbolize_keys))
    @expense_settlement.cash_handovers.map(&:save!)

    if(!params[:expense_settlement][:outbound_travel_id].blank?)
      OutboundTravel.set_as_processed(params[:expense_settlement][:outbound_travel_id])
    end

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
    redirect_to(expense_settlements_path, :flash => {:success => "Expense settlement e-mail successfully sent to '#{expense_report.profile.try(:common_name)}'"})
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
    inserted_record_count = load_to_db()
    redirect_to(show_uploads_expense_settlements_path, :flash => get_flash_message(inserted_record_count > 0,
                                                              "Totally #{inserted_record_count} records from file #{@file_name} are been uploaded successfully",
                                                              'No records uploaded. Either this file has already been uploaded or all rows have errors'))
  end

  def delete_expense
    file_name = params[:file_name]
    no_of_rows_deleted = Expense.delete_all(conditions: {file_name: file_name})
    doc_deleted = UploadedExpense.delete_all(conditions: {file_name: file_name})
    redirect_to(show_uploads_expense_settlements_path, :flash => get_flash_message(no_of_rows_deleted > 0 && doc_deleted ==1,
                                                              "File: '#{file_name}' has been deleted successfully",
                                                              'No records deleted'))
  end

  private
  def load_to_db
    tmp = params[:file_upload][:my_file].tempfile
    file = File.join("public", @file_name)
    FileUtils.cp(tmp.path, file)
    inserted_record_count = ExpenseImporter.new.load_expense(file)
    FileUtils.rm(file)
    inserted_record_count
  end

  def padded_dates(travel)
    @expenses_from_date = !params[:expense_from].blank? ? DateHelper.date_from_str(params[:expense_from]) : travel.departure_date - EXPENSE_DATES_PADDED_BY
    @expenses_to_date = !params[:expense_to].blank? ? DateHelper.date_from_str(params[:expense_to]) : (travel.return_date ? (travel.return_date + EXPENSE_DATES_PADDED_BY) : nil)
    @forex_from_date = !params[:forex_from].blank? ? DateHelper.date_from_str(params[:forex_from]) : travel.departure_date - FOREX_PAYMENT_DATES_PADDED_BY
    @forex_to_date = !params[:forex_to].blank? ? DateHelper.date_from_str(params[:forex_to]) : travel.return_date
  end

  def create_settlement_report_from_dates(empl_id, expense_settlement = nil)
    # TODO: Is this an ARel call?
    processed_expenses = ExpenseSettlement.load_processed_for(empl_id)
    processed_expense_hashes = processed_expenses.collect(&:expenses).flatten.compact
    processed_expense_ids = processed_expense_hashes.collect{|expense_hash| expense_hash['expense_id']}

    processed_forex_ids = processed_expenses.collect(&:forex_payments).flatten.compact

    @expenses = Expense.fetch_for_employee_between_dates(empl_id, @expenses_from_date, @expenses_to_date, processed_expense_ids)
    @forex_payments = ForexPayment.fetch_for(empl_id, @forex_from_date, @forex_to_date, processed_forex_ids)
    @applicable_currencies = ForexPayment.get_json_to_populate('currency')['currency']
    @payment_modes = [CashHandover::CASH, CashHandover::CREDIT_CARD]
    @has_cash_handovers = !expense_settlement.nil? && expense_settlement.cash_handovers.size() > 0
    @expense_settlement = expense_settlement || ExpenseSettlement.new(:id => nil,
                                                                  :empl_id => empl_id,
                                                                  :forex_payments => @forex_payments.collect(&:id),
                                                                  :expenses => @expenses.collect(&:id))
    @expense_settlement.cash_handovers << CashHandover.new if @expense_settlement.new_record?
  end

  def get_flash_message(flag, success_message, error_message)
    if(flag)
      return {:success => success_message}
    else
      return {:error => error_message}
    end
  end
end
