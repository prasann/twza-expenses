require 'spec_helper'

describe ExpenseReimbursement do
  it "should get expenses by project code" do
    expense_1 = Expense.create!(empl_id: 'EMP123', expense_date: '2011-12-14', project: 'Project', subproject: 'Sub Project 1')
    expense_2 = Expense.create!(empl_id: 'EMP123', expense_date: '2011-12-14', project: 'Project', subproject: 'Sub Project 1')
    expense_3 = Expense.create!(empl_id: 'EMP123', expense_date: '2011-12-14', project: 'Project', subproject: 'Sub Project 2')

    expenses = []
    expenses.push({'expense_id' => expense_1.id, 'modified_amount' => 1234})
    expenses.push({'expense_id' => expense_2.id, 'modified_amount' => 2345})
    expenses.push({'expense_id' => expense_3.id, 'modified_amount' => 3456})

    expense_reimbursement = ExpenseReimbursement.create!(:expenses => expenses)
    actual = expense_reimbursement.get_expenses_grouped_by_project_code

    actual["ProjectSub Project 1"].count.should == 2
    actual["ProjectSub Project 1"].should include(expense_1)
    actual["ProjectSub Project 1"].should include(expense_2)
    actual["ProjectSub Project 2"].count.should == 1
    actual["ProjectSub Project 2"].should include(expense_3)
    end

  it "should expense reports" do
    expense_1 = Expense.create!(empl_id: 'EMP123', expense_date: '2011-12-14', project: 'Project', subproject: 'Sub Project 1')
    expense_2 = Expense.create!(empl_id: 'EMP123', expense_date: '2011-12-14', project: 'Project', subproject: 'Sub Project 1')
    expense_3 = Expense.create!(empl_id: 'EMP123', expense_date: '2011-12-14', project: 'Project', subproject: 'Sub Project 2')

    expenses =[]
    expenses.push({'expense_id' => expense_1.id, 'modified_amount' => 1234})
    expenses.push({'expense_id' => expense_2.id, 'modified_amount' => 2345})
    expenses.push({'expense_id' => expense_3.id, 'modified_amount' => 3456})

    expense_reimbursement = ExpenseReimbursement.create!(:expenses => expenses)
    actual = expense_reimbursement.get_expenses

    actual.count.should == 3
    actual.should include(expense_1)
    actual.should include(expense_2)
    actual.should include(expense_3)
  end
end
