class EmployeeMailer < ActionMailer::Base
  @@EXPENSE_SETTLEMENT_SUBJECT = "Travel Expense Settlement"
  @@SENDER = "twindfinance@thoughtworks.com"

  default :from => @@SENDER
  def expense_settlement(profile,expense_report)
    mail(
        :to       =>  "padmana@thoughtworks.com",
        :subject  => @@EXPENSE_SETTLEMENT_SUBJECT
    )
  end
end
