FactoryGirl.define do
  factory :forex_payment do
    sequence(:emp_id) { |n| n }
    emp_name "Some name"
    amount { Random.rand(125) }
    currency 'INR'
    travel_date { Date.today }
    inr { Random.rand(5000) }
    issue_date { Date.today - 2.days }
    vendor_name 'VKC Forex'
  end

  factory :outbound_travel do
    sequence(:emp_id) { |n| n }
    emp_name "Some name"
    place 'US'
    departure_date { Time.now }
    # TODO: Not sure about this field - if its mandatory, then we should mark it as such in the model class
    # expected_return_date { Time.now + 2.days }
  end

  factory :expense do
    sequence(:empl_id) { |n| n }
    expense_date { Date.today - 10.days }
    expense_rpt_id { Random.rand(101010) }
    payment_type 'Personal Cash or Check'
    original_cost { BigDecimal.new('20.20') }
    original_currency 'USD'
    cost_in_home_currency {1000.90}
    report_submitted_at { Date.today }
  end

  factory :expense_reimbursement do
    sequence(:expense_report_id) { |n| n }
    sequence(:empl_id) { |n| "#{n}" }
    submitted_on { Time.now }
    total_amount { Random.rand(125) }
  end

  factory :cash_handover do
    amount { 100.0 }
    currency { 'EUR' }
    conversion_rate { 72.00 }
    payment_mode { CashHandover::CASH }
  end

  factory :expense_settlement do
    sequence(:empl_id) { |n| "#{n}" }
    sequence(:emp_name) { |n| "emp_name: #{n}" }
    expense_from { Date.today - 10.days }
    expense_to { Date.today - 5.days }
    forex_from { Date.today - 6.days }
    forex_to { Date.today - 3.days }
    status { ExpenseSettlement::GENERATED_DRAFT }
  end

  factory :bank_detail do
    sequence(:empl_id) { |n| "#{n}" }
    sequence(:empl_name) { |n| "empl_name: #{n}" }
    sequence(:account_no) { |n| "#{n}" }
  end

  factory :uploaded_expense do
    sequence(:file_name) { |n| "/tmp/uploaded_expense_#{$$}_#{n}" }
  end

  factory :user do
    sequence(:user_name) { |n| "user-#{n}" }
    sequence(:password) { |n| "#{Random.rand(123241)}-#{n}" }
  end
end
