require "#{Rails.root}/app/helpers/application_helper"

class EmployeeMailer < ActionMailer::Base
  helper ApplicationHelper

  EXPENSE_SETTLEMENT_SUBJECT = "Expense settlement for your travel to $place dated $start_date"
  EXPENSE_REIMBURSEMENT_SUBJECT = "Expense reimbursement for your expense report $expense_report_id"

  default :from => ::Rails.application.config.email_sender

  def expense_settlement(expense_report)
    @expense_report = expense_report
    @profile = @expense_report.profile
    travel = @expense_report.outbound_travel
    subject = EXPENSE_SETTLEMENT_SUBJECT.sub("$place", travel.place).sub('$start_date', DateHelper.date_fmt(travel.departure_date))

    mail(:to => @expense_report.employee_email, :subject => subject, :content_type => "text/html") do |format|
      format.html { render :action => 'expense_settlement' }
    end
  end

  def non_travel_expense_reimbursement(expense_reimbursement)
    @expense_reimbursement = expense_reimbursement
    @profile = @expense_reimbursement.profile
    @all_expenses = @expense_reimbursement.get_expenses_grouped_by_project_code
    @empl_name = @profile.get_full_name

    subject = EXPENSE_REIMBURSEMENT_SUBJECT.sub('$expense_report_id', @expense_reimbursement.expense_report_id.to_s)

    mail(:to => @expense_reimbursement.employee_email, :subject => subject, :content_type => "text/html") do |format|
      format.html { render :action => 'non_travel_expense_reimbursement' }
    end
  end
end
