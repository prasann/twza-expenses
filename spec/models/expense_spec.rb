require 'spec_helper'

describe 'expense' do
  it 'should be able to fetch the saved expense' do
    expense_123 = Expense.create(emp_id: '123', emp_name: 'Test1')
    expense_124 = Expense.create(emp_id: '124', emp_name: 'Test4')
    expense_123.save!
    expense_124.save!
    Expense.count.should == 2
    Expense.where(emp_id: '123').should == expense_123.to_a
  end
end
