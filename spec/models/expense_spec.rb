require 'spec_helper'

describe 'expense' do
  
  before(:each) do
	Expense.delete_all
  end

  it 'should be able to fetch reimbursable expenses for an employee between dates' do
    expense_1 = Expense.create(empl_id: 'EMP123', expense_date: '2011-12-14', payment_type: 'Personal Cash or Check')
    expense_2 = Expense.create(empl_id: 'EMP123', expense_date: '2011-12-15', payment_type: 'Personal Cash or Check')
    expense_3 = Expense.create(empl_id: 'EMP123', expense_date: '2011-12-20', payment_type: 'Personal Cash or Check')
    expense_4 = Expense.create(empl_id: 'EMP124', expense_date: '2011-12-14', payment_type: 'Personal Cash or Check')
    expense_5 = Expense.create(empl_id: 'EMP125', expense_date: '2011-12-14', payment_type: 'Personal Cash or Check')
    actual_result = Expense.fetch_for('123', Date.new(y=2011,m=12,d=14), Date.new(y=2011,m=12,d=16),[])
    actual_result.count.should == 2
  end
end

