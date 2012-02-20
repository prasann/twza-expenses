FactoryGirl.define do
  factory :forex_payment do
    sequence(:emp_id) { |n| "#{n}" }
    emp_name "Some name"
    amount { Random.rand(125) }
    currency 'INR'
    travel_date { Date.today }
    office 'Chennai'
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
  end

  factory :expense_reimbursement do
    sequence(:expense_report_id) { |n| "#{n}" }
    sequence(:empl_id) { |n| "#{n}" }
    submitted_on { Time.now }
    total_amount { Random.rand(125) }
    status ExpenseReimbursement::UNPROCESSED
  end
end
