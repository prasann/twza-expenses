require 'spec_helper'

describe ExpenseReimbursement do
  it "should get expenses by project code" do
    expense_1 = Factory(:expense, project: 'Project', subproject: 'Sub Project 1')
    expense_2 = Factory(:expense, project: 'Project', subproject: 'Sub Project 1')
    expense_3 = Factory(:expense, project: 'Project', subproject: 'Sub Project 2')
    expenses = [
      {'expense_id' => expense_1.id},
      {'expense_id' => expense_2.id},
      {'expense_id' => expense_3.id}
    ]
    expense_reimbursement = Factory(:expense_reimbursement, :expenses => expenses)

    actual = expense_reimbursement.get_expenses_grouped_by_project_code

    actual.size.should == 2
    actual["ProjectSub Project 1"].count.should == 2
    actual["ProjectSub Project 1"].should include(expense_1)
    actual["ProjectSub Project 1"].should include(expense_2)
    actual["ProjectSub Project 2"].count.should == 1
    actual["ProjectSub Project 2"].should include(expense_3)
  end

  it "should get expenses" do
    expense_1 = Factory(:expense)
    expense_2 = Factory(:expense)
    expense_3 = Factory(:expense)
    expenses = [
      {'expense_id' => expense_1.id},
      {'expense_id' => expense_2.id},
      {'expense_id' => expense_3.id}
    ]
    expense_reimbursement = Factory(:expense_reimbursement, :expenses => expenses)

    actual = expense_reimbursement.get_expenses

    actual.count.should == 3
    actual.should include(expense_1)
    actual.should include(expense_2)
    actual.should include(expense_3)
  end
end
