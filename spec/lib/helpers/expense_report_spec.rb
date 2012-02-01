require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require Rails.root.join("lib/helpers/expense_report_importer")
require Rails.root.join("app/models/expense")

describe "expense_report" do
  it "should convert header names to keys" do
    arr = ["A b", "Test This", "SOMETHING"]
    ExpenseReportImporter.convert_to_keys(arr)
    arr.should be == ["a_b", "test_this", "something"]
  end

  it "should convert a row to an expense" do
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
