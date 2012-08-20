# TODO: See if this can be just: require 'application_helper'
require "#{Rails.root}/app/helpers/application_helper"

class EmployeeMailer < ActionMailer::Base
  helper ApplicationHelper

  EXPENSE_SETTLEMENT_SUBJECT = "Expense settlement for your expenses from $start_date to $end_date"
  EXPENSE_REIMBURSEMENT_SUBJECT = "Expense reimbursement for your expense report $expense_report_id"

  default :from => ::Rails.application.config.email_sender

  def expense_settlement(expense_settlement)
    @expense_settlement = expense_settlement
    @empl_name = @expense_settlement.employee_detail.try(:emp_name) || ""
    subject = EXPENSE_SETTLEMENT_SUBJECT.sub("$start_date", DateHelper.date_fmt(@expense_settlement.expense_from)).sub('$end_date', DateHelper.date_fmt(@expense_settlement.expense_to))
    subject.insert(0, "#{Rails.env} - ") unless Rails.env.production?

    mail(:to => to_address(expense_settlement.empl_id), :subject => subject, :content_type => "text/html") do |format|
      format.html { render :action => 'expense_settlement' }
    end
  end

  def non_travel_expense_reimbursement(expense_reimbursement)
    @expense_reimbursement = expense_reimbursement
    @empl_name = @expense_reimbursement.employee_detail.try(:emp_name) || ""
    @employee_detail = @expense_reimbursement.employee_detail
    @all_expenses = @expense_reimbursement.get_expenses_grouped_by_project_code

    subject = EXPENSE_REIMBURSEMENT_SUBJECT.sub('$expense_report_id', @expense_reimbursement.expense_report_id.to_s)
    subject.insert(0, "#{Rails.env} - ") unless Rails.env.production?

    mail(:to => to_address(expense_reimbursement.empl_id), :subject => subject, :content_type => "text/html") do |format|
      format.html { render :action => 'non_travel_expense_reimbursement' }
    end
  end

  def to_address(emp_id)
    emp_id << "@thoughtworks.com"
  end
end
