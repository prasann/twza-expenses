require 'spec_helper'

describe 'expense' do
  before(:each) do
    Expense.delete_all
  end

  it 'should be able to fetch reimbursable expenses for an employee between dates' do
    expense_1 = Factory(:expense, :empl_id => 123, :expense_date => Date.parse('2011-12-14'), :payment_type => 'Personal Cash or Check')
    expense_2 = Factory(:expense, :empl_id => 123, :expense_date => Date.parse('2011-12-15'), :payment_type => 'Personal Cash or Check')
    expense_3 = Factory(:expense, :empl_id => 123, :expense_date => Date.parse('2011-12-20'), :payment_type => 'Personal Cash or Check')
    expense_4 = Factory(:expense, :empl_id => 124, :expense_date => Date.parse('2011-12-14'), :payment_type => 'Personal Cash or Check')
    expense_5 = Factory(:expense, :empl_id => 125, :expense_date => Date.parse('2011-12-14'), :payment_type => 'Personal Cash or Check')
   
    actual_result = Expense.fetch_for_employee_between_dates(123, Date.new(y=2011,m=12,d=14), Date.new(y=2011,m=12,d=16),[])
    actual_result.count.should == 2
  end

  it 'should be able to fetch reimbursable expenses for an employee excluding TW Billed by Vendor' do
    expense_1 = Factory(:expense, :empl_id => 123, :expense_date => Date.parse('2011-12-14'), :payment_type => 'TW Billed by Vendor')
    expense_2 = Factory(:expense, :empl_id => 123, :expense_date => Date.parse('2011-12-15'), :payment_type => 'Personal Cash or Check')
    expense_3 = Factory(:expense, :empl_id => 123, :expense_date => Date.parse('2011-12-20'), :payment_type => 'Personal Cash or Check')
    expense_4 = Factory(:expense, :empl_id => 124, :expense_date => Date.parse('2011-12-14'), :payment_type => 'Personal Cash or Check')
    expense_5 = Factory(:expense, :empl_id => 125, :expense_date => Date.parse('2011-12-14'), :payment_type => 'Personal Cash or Check')
    actual_result = Expense.fetch_for_employee_between_dates(123, Date.new(y=2011,m=12,d=14), Date.new(y=2011,m=12,d=16),[])
    actual_result.count.should == 1
  end
end
