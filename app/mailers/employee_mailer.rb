require "#{Rails.root}/app/helpers/application_helper"

class EmployeeMailer < ActionMailer::Base
  helper ApplicationHelper

  EXPENSE_SETTLEMENT_SUBJECT = "Expense settlement for your travel to $place dated $start_date"

  default :from => ::Rails.application.config.email_sender

  def expense_settlement(profile, expense_report)
    @expense_report = expense_report
    @profile = profile
    email_id = profile.email_id
    travel = @expense_report.outbound_travel
    subject = EXPENSE_SETTLEMENT_SUBJECT.sub("$place",travel.place)
                                          .sub('$start_date',travel.departure_date.strftime("%d-%b-%Y"))
    if (profile.email_id == nil || profile.email_id.length == 0)
      email_id = expense_report.empl_id.to_s
    end

    mail(:to => email_id + ::Rails.application.config.email_domain, :subject => subject, :content_type => "text/html") do |format|
      format.html { render :action => 'expense_settlement' }
    end
  end
end