require 'spec_helper'

describe "expense_report" do
  it "should convert a row to an expense" do
    pending "should stub read from excel and test if expense is created"
    expense = Expense.new

    expected_row_obj = Hash.new
    expected_row_obj["a_b"] = 1
    expected_row_obj["test_this"] = "value"
    expected_row_obj["something"] = 55.55

    Expense.stub!(:create).with(expected_row_obj).and_return(expense)
    result_proc = ExpenseReportImporter.create_expense(["a_b", "test_this", "something"])
    actual_expense = result_proc.call([1,"value",55.55])
    actual_expense.should be == expense
  end
end
