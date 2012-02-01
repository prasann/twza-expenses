require "#{Rails.root}/app/helpers/application_helper"

class EmployeeMailer < ActionMailer::Base
  helper ApplicationHelper

  EXPENSE_SETTLEMENT_SUBJECT = "Expense settlement for your travel to $place dated $start_date"
  EXPENSE_REIMBURSEMENT_SUBJECT = "Expense reimbursement for your expense report $expense_report_id"

  default :from => ::Rails.application.config.email_sender

  def expense_settlement(expense_report)
    @expense_report = expense_report
    @profile = @expense_report.profile
    email_id = @profile.email_id.blank? ? expense_report.empl_id.to_s : @profile.email_id
    travel = @expense_report.outbound_travel
    subject = EXPENSE_SETTLEMENT_SUBJECT.sub("$place", travel.place).sub('$start_date', travel.departure_date.strftime("%d-%b-%Y"))

    mail(:to => email_id + ::Rails.application.config.email_domain, :subject => subject, :content_type => "text/html") do |format|
      format.html { render :action => 'expense_settlement' }
    end
  end

  def non_travel_expense_reimbursement(profile, expense_reimbursement)
    @profile = profile
    @expense_reimbursement = expense_reimbursement
    @all_expenses = @expense_reimbursement.get_expenses_grouped_by_project_code
    @empl_name = profile.get_full_name

    email_id = profile.email_id
    subject = EXPENSE_REIMBURSEMENT_SUBJECT.sub('$expense_report_id', expense_reimbursement.expense_report_id.to_s)
    if (profile.email_id == nil || profile.email_id.length == 0)
      email_id = expense_reimbursement.empl_id.to_s
    end

    mail(:to => email_id + ::Rails.application.config.email_domain, :subject => subject, :content_type => "text/html") do |format|
      format.html { render :action => 'non_travel_expense_reimbursement' }
    end
  end
end