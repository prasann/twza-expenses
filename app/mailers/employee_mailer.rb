require "#{Rails.root}/app/helpers/application_helper"

class EmployeeMailer < ActionMailer::Base
  helper ApplicationHelper

  @@EXPENSE_SETTLEMENT_SUBJECT = "Travel Expense Settlement"
  @@SENDER = "twindfinance@thoughtworks.com"

  default :from => @@SENDER

  def expense_settlement(profile, expense_report)
    @expense_report = expense_report
    @profile = profile
    travel = @expense_report.outbound_travel
    subject = @@EXPENSE_SETTLEMENT_SUBJECT + ' to ' + travel.place + ' starting ' + travel.departure_date.strftime("%d-%b-%Y")
    mail(:to => "padmana@thoughtworks.com", :subject => subject, :content_type => "text/html") do |format|
      format.html { render :action => 'expense_settlement' }
    end
  end
end