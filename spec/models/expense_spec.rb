require 'spec_helper'

describe Expense do
  before(:each) do
    Expense.delete_all
  end

  describe "validations" do
    it { should validate_presence_of(:empl_id) }
    it { should validate_presence_of(:expense_rpt_id) }
    it { should validate_presence_of(:payment_type) }
    it { should validate_presence_of(:original_cost) }
    it { should validate_presence_of(:original_currency) }
    it { should validate_presence_of(:cost_in_home_currency) }
    it { should validate_presence_of(:expense_date) }
    it { should validate_presence_of(:report_submitted_at) }
  end

  describe "fields" do
    let(:expense) { FactoryGirl.create(:expense) }

    it { should contain_field(:empl_id, :type => Integer) }
    it { should contain_field(:expense_rpt_id, :type => Integer) }
    it { should contain_field(:original_cost, :type => BigDecimal) }
    it { should contain_field(:original_currency, :type => String) }
    it { should contain_field(:cost_in_home_currency, :type => BigDecimal) }
    it { should contain_field(:expense_date, :type => Date) }
    it { should contain_field(:report_submitted_at, :type => Date) }
    it { should contain_field(:payment_type, :type => String) }
    it { should contain_field(:project, :type => String) }
    it { should contain_field(:subproject, :type => String) }
    it { should contain_field(:vendor, :type => String) }
    it { should contain_field(:is_personal, :type => String) }
    it { should contain_field(:attendees, :type => String) }
    it { should contain_field(:expense_type, :type => String) }
    it { should contain_field(:description, :type => String) }
  end

  describe "for_empl_id" do
    it "should be tested"
  end

  describe "for_expense_report_id" do
    it "should be tested"
  end

  describe "fetch_for_employee_between_dates" do
    it 'should be able to fetch reimbursable expenses for an employee between dates' do
      expense_1 = FactoryGirl.create(:expense, :empl_id => 123, :expense_date => DateHelper.date_from_str('2011-12-14'), :payment_type => 'Personal Cash or Check')
      expense_2 = FactoryGirl.create(:expense, :empl_id => 123, :expense_date => DateHelper.date_from_str('2011-12-15'))
      expense_3 = FactoryGirl.create(:expense, :empl_id => 123, :expense_date => DateHelper.date_from_str('2011-12-20'))
      expense_4 = FactoryGirl.create(:expense, :empl_id => 124, :expense_date => DateHelper.date_from_str('2011-12-14'))
      expense_5 = FactoryGirl.create(:expense, :empl_id => 125, :expense_date => DateHelper.date_from_str('2011-12-14'))

      actual_result = Expense.fetch_for_employee_between_dates(123, Date.new(y=2011,m=12,d=14), Date.new(y=2011,m=12,d=16),[])
      actual_result.count.should == 2
    end

    it 'should not fetch reimbursable expenses of payment type TW Billed by Vendor' do
      expense_1 = FactoryGirl.create(:expense, :empl_id => 123, :expense_date => DateHelper.date_from_str('2011-12-14'), :payment_type => 'TW Billed by Vendor')
      expense_2 = FactoryGirl.create(:expense, :empl_id => 123, :expense_date => DateHelper.date_from_str('2011-12-15'), :payment_type => 'Personal Cash or Check')
      expense_3 = FactoryGirl.create(:expense, :empl_id => 123, :expense_date => DateHelper.date_from_str('2011-12-20'))
      expense_4 = FactoryGirl.create(:expense, :empl_id => 124, :expense_date => DateHelper.date_from_str('2011-12-14'))
      expense_5 = FactoryGirl.create(:expense, :empl_id => 125, :expense_date => DateHelper.date_from_str('2011-12-14'))
      actual_result = Expense.fetch_for_employee_between_dates(123, Date.new(y=2011,m=12,d=14), Date.new(y=2011,m=12,d=16),[])
      actual_result.count.should == 1
    end
  end

  describe "fetch_for" do
    it "should be tested"
  end

  describe "fetch_for_grouped_by_report_id" do
    it "should be tested"
  end

  describe "profile" do
    it "should be tested"
  end

  describe "project_subproject" do
    it "should be tested"
  end

  describe "get_employee_id" do
    it "should be tested"
  end
end
