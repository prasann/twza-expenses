require 'mongoid'
require 'helpers/expense_report_importer'

class ExpenseSettlementController < ApplicationController
  FOREX_PAYMENT_DATES_PADDED_BY=15
  EXPENSE_DATES_PADDED_BY=5

  def index
    default_per_page = params[:per_page] || 20
    if !params[:empl_id].blank?
      # TODO: These are not being evaluated - but are used in the view as is?
      @expense_settlements = ExpenseSettlement.for_empl_id(params[:empl_id]).page(params[:page]).per(default_per_page)
    else
      # TODO: These are not being evaluated - but are used in the view as is?
      @expense_settlements = ExpenseSettlement.page(params[:page]).per(default_per_page)
    end
    render :layout => 'tabs'
  end

  def load_by_travel
    travel = OutboundTravel.find(params[:id])
    padded_dates(travel)
    create_settlement_report_from_dates(travel)
  end

  def edit
    settlement_from_db = ExpenseSettlement.find(params[:id])
    settlement_from_db.populate_instance_data
    @expenses_from_date = DateHelper.date_from_str(settlement_from_db.expense_from)
    @expenses_to_date = DateHelper.date_from_str(settlement_from_db.expense_to)
    @forex_from_date = DateHelper.date_from_str(settlement_from_db.forex_from)
    @forex_to_date = DateHelper.date_from_str(settlement_from_db.forex_to)
    create_settlement_report_from_dates(settlement_from_db.outbound_travel)
    @expense_report["id"] = settlement_from_db.id.to_s
    render 'load_by_travel'
  end

  def show
    @expense_report = ExpenseSettlement.find(params[:id])
    @expense_report.populate_instance_data
    render 'generate_report'
  end

  def generate_report
    outbound_travel = OutboundTravel.find(params[:travel_id])
    @expense_report = outbound_travel.find_or_initialize_expense_settlement
    @expense_report.update_attributes({:cash_handover => params[:cash_handover].to_i, 
									   :status => 'Generated Draft'}.merge(params.slice(:expenses, :forex_payments, 
									 					  							   :emp_name, :empl_id, :expense_from, 
																					   :expense_to, :forex_from, :forex_to).symbolize_keys)
									    )
    @expense_report.populate_instance_data
  end

  def set_processed
    expense_report = ExpenseSettlement.find(params[:id])
    expense_report.complete
    redirect_to outbound_travels_path
  end

  def notify
    expense_report = ExpenseSettlement.find(params[:id])
    expense_report.notify_employee
    # TODO: What if the save failed?
    flash[:success] = "Expense settlement e-mail successfully sent to '" + expense_report.profile.common_name + "'"
    redirect_to(:action => :index, :anchor => 'expense_settlement', :empl_id => expense_report.empl_id)
  end

  def upload
    @uploaded_files = UploadedExpense.desc(:created_at)
  end

  def file_upload
    require 'fileutils'
    @file_name = params[:file_upload][:my_file].original_filename
    if load_to_db
      flash[:success] = 'File: ' + @file_name + ' has been uploaded successfully'
      redirect_to :action => 'upload'
    else
      flash[:error] = 'This file has already been uploaded'
      redirect_to :action => 'upload'
    end
  end

  private
  def load_to_db
    tmp = params[:file_upload][:my_file].tempfile
    file = File.join("public", @file_name)
    FileUtils.cp(tmp.path, file)
    success = ExpenseReportImporter.load_expense(file)
    FileUtils.rm(file)
    success
  end

  def padded_dates(travel)
    @expenses_from_date = params[:expense_from] ? DateHelper.date_from_str(params[:expense_from]) : travel.departure_date - EXPENSE_DATES_PADDED_BY
    @expenses_to_date = params[:expense_to] ? DateHelper.date_from_str(params[:expense_to]) : (travel.return_date ? (travel.return_date + EXPENSE_DATES_PADDED_BY) : nil)
    @forex_from_date = params[:forex_from] ? DateHelper.date_from_str(params[:forex_from]) : travel.departure_date - FOREX_PAYMENT_DATES_PADDED_BY
    @forex_to_date = params[:forex_to] ? DateHelper.date_from_str(params[:forex_to]) : travel.return_date
  end

  def create_settlement_report_from_dates(travel)
    # TODO: Is this an ARel call?
    processed_expenses = ExpenseSettlement.where(processed: true).for_empl_id(travel.emp_id.to_s).only(:expenses, :forex_payments).to_a
    processed_expense_ids = processed_expenses.collect(&:expenses).flatten
    processed_forex_ids = processed_expenses.collect(&:forex_payments).flatten

    expenses = Expense.fetch_for_employee_between_dates travel.emp_id, @expenses_from_date, @expenses_to_date, processed_expense_ids
    forex_payments = ForexPayment.fetch_for travel.emp_id, @forex_from_date, @forex_to_date, processed_forex_ids
    @all_currencies = forex_payments.collect(&:currency)
    @expense_report = {"expenses" => expenses,
                       "forex_payments" => forex_payments,
                       "empl_id" => travel.emp_id,
                       "travel_id" => travel.id.to_s}
  end
end
