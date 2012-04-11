require 'spec_helper'

describe ExpenseSettlement do
  describe "validations" do
    it { should validate_presence_of(:empl_id) }
    it { should validate_presence_of(:emp_name) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:expense_from) }
    it { should validate_presence_of(:expense_to) }
    it { should validate_presence_of(:forex_from) }
    it { should validate_presence_of(:forex_to) }

    it { should allow_value(ExpenseSettlement::GENERATED_DRAFT).for(:status) }
    it { should allow_value(ExpenseSettlement::NOTIFIED_EMPLOYEE).for(:status) }
    it { should allow_value(ExpenseSettlement::COMPLETE).for(:status) }
    it { should allow_value(ExpenseSettlement::CLOSED).for(:status) }
  end

  describe "relationships" do
    xit { should have_many(:cash_handovers) }
  end

  describe "fields" do
    let(:expense_settlement) { FactoryGirl.create(:expense_settlement) }

    it { should contain_field(:expenses, :type => Array) }
    it { should contain_field(:forex_payments, :type => Array) }
    it { should contain_field(:empl_id, :type => String) }
    it { should contain_field(:emp_name, :type => String) }
    it { should contain_field(:status, :type => String) }
  end

  describe "for_empl_id" do
    it "should be tested"
  end

  describe "with_status" do
    it "should be tested"
  end

  describe "find_expense_ids_for_empl_id" do
    it "should be tested"
  end

  describe "load_processed_for" do
    it "should be tested"
  end

  describe "profile" do
    it "should be tested"
  end

  describe "email_id" do
    it "should be tested"
  end

  describe "get_consolidated_expenses" do
    it "should consolidate expenses by rpt and currency considering conversion rate" do
      persisted_expenses = [
                  FactoryGirl.create(:expense, :expense_rpt_id => 123, :original_currency => 'EUR', :original_cost => BigDecimal.new('200'), :cost_in_home_currency => BigDecimal.new('200')),
                  FactoryGirl.create(:expense, :expense_rpt_id => 122, :original_currency => 'EUR', :original_cost => BigDecimal.new('100'), :cost_in_home_currency => BigDecimal.new('100')),
                  FactoryGirl.create(:expense, :expense_rpt_id => 121, :original_currency => 'INR', :original_cost => BigDecimal.new('1000'),:cost_in_home_currency => BigDecimal.new('4000')),
                  FactoryGirl.create(:expense, :expense_rpt_id => 121, :original_currency => 'EUR', :original_cost => BigDecimal.new('100'), :cost_in_home_currency => BigDecimal.new('100')),
                  FactoryGirl.create(:expense, :expense_rpt_id => 121, :original_currency => 'EUR', :original_cost => BigDecimal.new('200'), :cost_in_home_currency => BigDecimal.new('200'))
                ]
      forex_payments = [FactoryGirl.create(:forex_payment, :currency => 'EUR', :inr => 100, :amount => 100)]
      exp_rpt = FactoryGirl.create(:expense_settlement, :expenses => persisted_expenses.collect(&:id))
      expected_hash_1 = {'report_id' => 123, 'currency' => 'EUR', 'amount' => 200, 'conversion_rate' => 1, 'local_currency_amount' => 200}
      expected_hash_2 = {'report_id' => 122, 'currency' => 'EUR', 'amount' => 100, 'conversion_rate' => 1, 'local_currency_amount' => 100}
      expected_hash_3 = {'report_id' => 121, 'currency' => 'EUR', 'amount' => 300, 'conversion_rate' => 1, 'local_currency_amount' => 300}
      expected_hash_4 = {'report_id' => 121, 'currency' => 'INR', 'amount' => 1000, 'conversion_rate' => 4, 'local_currency_amount' => 4000}

      exp_rpt.populate_instance_data

      actual_consolidated = exp_rpt.get_consolidated_expenses
      actual_consolidated.count.should == 4
      actual_consolidated.should include(expected_hash_1)
      actual_consolidated.should include(expected_hash_2)
      actual_consolidated.should include(expected_hash_3)
      actual_consolidated.should include(expected_hash_4)
    end

    it "should consolidate expenses by rpt and currency considering conversion rate from sharon sheet if no forex is available" do
      persisted_expenses = [
                  FactoryGirl.create(:expense, :expense_rpt_id => 123, :original_currency => 'EUR', :original_cost => BigDecimal.new('200'), :cost_in_home_currency => BigDecimal.new('200')),
                  FactoryGirl.create(:expense, :expense_rpt_id => 122, :original_currency => 'EUR', :original_cost => BigDecimal.new('100'), :cost_in_home_currency => BigDecimal.new('100')),
                  FactoryGirl.create(:expense, :expense_rpt_id => 121, :original_currency => 'INR', :original_cost => BigDecimal.new('1000'),:cost_in_home_currency => BigDecimal.new('4000')),
                  FactoryGirl.create(:expense, :expense_rpt_id => 121, :original_currency => 'EUR', :original_cost => BigDecimal.new('100'), :cost_in_home_currency => BigDecimal.new('100')),
                  FactoryGirl.create(:expense, :expense_rpt_id => 121, :original_currency => 'EUR', :original_cost => BigDecimal.new('200'), :cost_in_home_currency => BigDecimal.new('200'))
                ]

      exp_rpt = FactoryGirl.create(:expense_settlement, :expenses => persisted_expenses.collect(&:id))
      expected_hash_1 = {'report_id' => 123, 'currency' => 'EUR', 'amount' => 200, 'conversion_rate' => 1, 'local_currency_amount' => 200}
      expected_hash_2 = {'report_id' => 122, 'currency' => 'EUR', 'amount' => 100, 'conversion_rate' => 1, 'local_currency_amount' => 100}
      expected_hash_3 = {'report_id' => 121, 'currency' => 'EUR', 'amount' => 300, 'conversion_rate' => 1, 'local_currency_amount' => 300}
      expected_hash_4 = {'report_id' => 121, 'currency' => 'INR', 'amount' => 1000, 'conversion_rate' => 4, 'local_currency_amount' => 4000}

      exp_rpt.populate_instance_data

      actual_consolidated = exp_rpt.get_consolidated_expenses

      actual_consolidated.count.should == 4
      actual_consolidated.should include(expected_hash_1)
      actual_consolidated.should include(expected_hash_2)
      actual_consolidated.should include(expected_hash_3)
      actual_consolidated.should include(expected_hash_4)
    end
  end

  describe "get_conversion_rates_for_currency" do
    it "should provide average forex rate for each currency" do
      forex_payments = [FactoryGirl.create(:forex_payment, :currency => 'EUR', :inr => 2000, :amount => 100),
              FactoryGirl.create(:forex_payment, :currency => 'EUR', :inr => 1800, :amount => 100),
              FactoryGirl.create(:forex_payment, :currency => 'EUR', :inr => 950, :amount => 50),
              FactoryGirl.create(:forex_payment, :currency => 'USD', :inr => 1000, :amount => 100),
              FactoryGirl.create(:forex_payment, :currency => 'USD', :inr => 810, :amount => 90)]

      exp_rpt = FactoryGirl.create(:expense_settlement, :forex_payments => forex_payments.collect(&:id))
      exp_rpt.populate_forex_payments
      actual_conv_rates = exp_rpt.get_conversion_rates_for_currency
      actual_conv_rates.values.count == 2
      ((actual_conv_rates["USD"]*100).round.to_f/100).should == (((1000+810).to_f/(100+90))*100).round.to_f/100
      ((actual_conv_rates["EUR"]*100).round.to_f/100).should == (((2000+1800+950).to_f/(100+100+50))*100).round.to_f/100
    end
  end

  describe "employee_email" do
    it "should return employee id appended with e-mail domain as employee e-mail ID if email_id is not available" do
      profile = Profile.new(:email_id => '')
      expense_settlement = FactoryGirl.build(:expense_settlement, :empl_id => 13552)
      expense_settlement.should_receive(:profile).exactly(2).times.and_return(profile)
      email = expense_settlement.employee_email
      email.should == '13552' + ::Rails.application.config.email_domain
    end

    it "should return e-mail ID as employee email if it is available" do
      profile = Profile.new(:email_id => 'johns')
      expense_settlement = FactoryGirl.build(:expense_settlement)
      expense_settlement.should_receive(:profile).exactly(3).times.and_return(profile)
      email = expense_settlement.employee_email
      email.should == 'johns' + ::Rails.application.config.email_domain
    end
  end

  describe "populate_instance_data" do
    it "should compute settlement properly when forex of multiple currencies are involved" do
      employee_id = '12321'
      test_forex_currencies = ['EUR', 'GBP']
      expense_amounts = [BigDecimal.new('300'), BigDecimal.new('750')]
      expense_amounts_inr = [BigDecimal.new('23032.5'), BigDecimal.new('47437.5')]
      forex_amounts = [500, 1000]
      forex_amounts_inr = [37309, 62728.5]
      outbound_travel = FactoryGirl.create(:outbound_travel, :place => 'UK', :emp_id => employee_id,
                                :departure_date => Date.today - 10, :return_date => Date.today + 5)
      travel_id = outbound_travel.id
      expenses = []
      forex_payments = []
      cash_handovers = [FactoryGirl.create(:cash_handover, :amount => 100, :currency => 'EUR', :conversion_rate => 74.62),
                        FactoryGirl.create(:cash_handover, :amount => 150, :currency => 'GBP', :conversion_rate => 62.73)]

      test_forex_currencies.each_with_index do |currency, index|
        expenses << FactoryGirl.create(:expense, :empl_id => employee_id, :original_currency => currency,
                            :cost_in_home_currency => expense_amounts_inr[index], :expense_rpt_id => index,
                            :original_cost => expense_amounts[index])

        forex_payments << FactoryGirl.create(:forex_payment, :emp_id => employee_id, :currency => currency,
                                  :place => 'UK', :amount => forex_amounts[index], :inr => forex_amounts_inr[index])
      end

      expense_settlement = FactoryGirl.create(:expense_settlement, :empl_id => employee_id,
                                   :expenses => expenses.collect(&:id),
                                   :forex_payments => forex_payments.collect(&:id),
                                   :cash_handovers => cash_handovers)

      expense_settlement.populate_instance_data
      expense_settlement.instance_variable_get('@net_payable').should eq 13732.5
    end
  end

  describe "load_with_deps" do
    it "should load cash handovers and expenses eagerly on call of load with deps" do
      settlement = FactoryGirl.create(:expense_settlement)
      mock_criteria = mock('Object')
      ExpenseSettlement.should_receive(:includes).with(:cash_handovers).and_return(mock_criteria)
      mock_criteria.should_receive(:find).with(settlement.id).and_return(settlement)
      settlement.should_receive(:populate_instance_data)

      ExpenseSettlement.load_with_deps(settlement.id)
    end
  end

  describe "notify_employee" do
    it "should be tested"
  end

  describe "complete" do
    it "should be tested"
  end

  describe "close" do
    it "should be tested"
  end

  describe "is_generated_draft?" do
    it "should be tested"
  end

  describe "is_complete?" do
    it "should be tested"
  end

  describe "is_notified_employee?" do
    it "should be tested"
  end

  describe "is_closed?" do
    it "should be tested"
  end

  describe "is_editable?" do
    it "should be tested"
  end

  describe "populate_consolidated_expenses" do
    it "should be tested"
  end

  describe "consolidate_by_currency" do
    it "should be tested"
  end

  describe "populate_forex_payments" do
    it "should be tested"
  end

  describe "get_conversion_rate" do
    it "should be tested"
  end

  describe "get_conversion_rate_for" do
    it "should be tested"
  end

  describe "total_cash_handover_amount" do
    it "should be tested"
  end

  describe "get_receivable_amount" do
    it "should be tested"
  end

  describe "get_reimbursable_expense_reports" do
    it "should be tested"
  end

  describe "get_forex_payments" do
    it "should be tested"
  end

  describe "get_consolidated_expenses" do
    it "should be tested"
  end

  describe "get_unique_report_ids" do
    it "should be tested"
  end

  describe "create_bank_reimbursement" do
    it "should be tested"
  end
end
