FactoryGirl.define do
  factory :forex_payment do
    sequence(:emp_id) { |n| "#{n}" }
    emp_name "Some name"
    amount { Random.rand(125) }
    currency 'INR'
    travel_date { Date.today }
    inr { Random.rand(5000) }
    issue_date { Date.today - 2.days }
    vendor_name 'VKC Forex'
  end

  factory :outbound_travel do
    sequence(:emp_id) { |n| "#{n}" }
    emp_name "Some name"
    place 'US'
    departure_date { Time.now }
    # TODO: Not sure about this field - if its mandatory, then we should mark it as such in the model class
    # expected_return_date { Time.now + 2.days }
  end

  factory :expense do
    sequence(:empl_id) { |n| "#{n}" }
    expense_date { Date.today - 10.days }
    expense_rpt_id { Random.rand(101010) }
    payment_type 'Personal Cash or Check'
    original_cost { BigDecimal.new('20.20') }
    original_currency 'USD'
    cost_in_home_currency {1000.90}
    report_submitted_at { Date.today }
  end

  factory :expense_reimbursement do
    sequence(:expense_report_id) { |n| "#{n}" }
    sequence(:empl_id) { |n| "#{n}" }
    submitted_on { Time.now }
    total_amount { Random.rand(125) }
    status ExpenseReimbursement::UNPROCESSED
  end

  factory :cash_handover do
    amount {100}
    currency {'EUR'}
    conversion_rate {72.00}
    payment_mode {'CASH'}
  end

  factory :expense_settlement do
    sequence(:empl_id) { |n| "#{n}" }
    association :outbound_travel
    status { ExpenseSettlement::GENERATED_DRAFT }
  end

  factory :bank_detail do
    sequence(:empl_id) { |n| "#{n}" }
    sequence(:account_no) { |n| "#{n}" }
  end
end
