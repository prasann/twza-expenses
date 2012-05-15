require 'spec_helper'

describe ExpenseImporter do
  it "should convert a row to an expense" do
    #pending "should stub read from excel and test if expense is created"
    file_with_valid_expenses = "data/file1"
    file_with_invalid_expense = "data/file2"
    Dir.should_receive(:glob).and_return([file_with_valid_expenses, file_with_invalid_expense])
    importer = ExpenseImporter.new
    Expense.delete_all
    importer.should_receive(:read_from_excel).with(file_with_valid_expenses, 0).and_return do |filename, sheetno, &block|
      10
    end

    importer.should_receive(:read_from_excel).with(file_with_invalid_expense, 0).and_return do |filename, sheetno, &block|
      0
    end

    UploadedExpense.should_receive(:create!).with(file_name: "file1")
    UploadedExpense.should_not_receive(:create!).with(file_name: "file2")

    importer.load

    Expense.find(:all).count.should == 2
  end
end
