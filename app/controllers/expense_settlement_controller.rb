require 'mongoid'
require 'helpers/expense_report'

class ExpenseSettlementController < ApplicationController
  FOREX_PAYMENT_DATES_PADDED_BY=15
  EXPENSE_DATES_PADDED_BY=5

  def index
    default_per_page = params[:per_page] || 20
    if(params[:empl_id])
      @expense_settlements = ExpenseReport.where(empl_id: params[:empl_id])
      .page(params[:page]).per(default_per_page)
    else
      @expense_settlements = ExpenseReport
      .page(params[:page]).per(default_per_page)
    end
    render :layout => 'tabs'
  end

  def load_by_travel
    travel = OutboundTravel.find(params[:id])
    padded_dates(travel)
    processed_expenses = ExpenseReport.where(empl_id:travel.emp_id.to_s, processed: true).only(:expenses, :forex_payments).to_a
    processed_expense_ids = processed_expenses.collect(&:expenses).flatten
    processed_forex_ids = processed_expenses.collect(&:forex_payments).flatten

    expenses = Expense.fetch_for travel.emp_id,@expenses_from_date,@expenses_to_date,processed_expense_ids
    forex_payments = ForexPayment.fetch_for travel.emp_id,@forex_from_date,@forex_to_date, processed_forex_ids
    @expense_report = ExpenseReport.new(:expenses => expenses,
    :forex_payments => forex_payments,
    :empl_id => travel.emp_id,
    :travel_id => travel.id.to_s)
  end

  def generate_report
    outbound_travel = OutboundTravel.find(params[:travel_id])
    outbound_travel.create_expense_report(expenses: params[:expenses],
    forex_payments: params[:forex_payments],
    cash_handover: params[:cash_handover].to_i,
    empl_id: params[:empl_id],
    processed: false)

    @expense_report = outbound_travel.expense_report
    @expense_report.populate_instance_data()
    @expense_report
  end

  def set_processed
    expense_report = ExpenseReport.find(params[:id])
    expense_report.processed = true
    expense_report.save
    redirect_to outbound_travels_path
  end

  def notify
    expense_report = ExpenseReport.find(params[:id])
	expense_report.populate_instance_data
    profile = Profile.find_all_by_employee_id(expense_report.empl_id)
    EmployeeMailer.expense_settlement(profile, expense_report).deliver
    redirect_to(:back)
  end
  
  def file_upload  
	  require 'fileutils'
	  tmp = params[:file_upload][:my_file].tempfile
	  file = File.join("public", params[:file_upload][:my_file].original_filename)
	  FileUtils.cp tmp.path, file
	  ExpenseReport.load_expense(file)
	  FileUtils.rm file
	  render :upload_success
  end
  
  private
  def padded_dates(travel)
    @expenses_from_date = params[:expense_from] ? Date.parse(params[:expense_from]) : travel.departure_date - EXPENSE_DATES_PADDED_BY
    @expenses_to_date = params[:expense_to] ? Date.parse(params[:expense_to]) : travel.return_date + EXPENSE_DATES_PADDED_BY
    @forex_from_date = params[:forex_from] ? Date.parse(params[:forex_from]) : travel.departure_date - FOREX_PAYMENT_DATES_PADDED_BY
    @forex_to_date = params[:forex_to] ? Date.parse(params[:forex_to]) : travel.return_date + FOREX_PAYMENT_DATES_PADDED_BY
  end
end
