require 'spec_helper'

describe ExpenseImporter do
  it "should convert a row to an expense" do
    #pending "should stub read from excel and test if expense is created"
    file_with_valid_expenses = "data/file1"
    file_with_invalid_expense = "data/file2"
    Dir.should_receive(:glob).and_return([file_with_valid_expenses, file_with_invalid_expense])
    importer = ExpenseImporter.new
    Expense.delete_all
    importer.stub!(:read_from_excel).with(file_with_valid_expenses, 0).and_return do |filename, sheetno, &block|
      file = mock('Excel')

      def file.cell(line, column)
        return BigDecimal.new('100') if ['N', 'E'].include?(column)
        return DateHelper::date_fmt(Date.today) if ['J', 'T'].include?(column)
        'some text'
      end

      1.upto(2) do |line|
        extractor = Proc.new { |column|
          file.cell(line, column)
        }

        expense = block.call(extractor)
        expense.save!
      end
    end

    importer.stub!(:read_from_excel).with(file_with_invalid_expense, 0).and_return do |filename, sheetno, &block|
      file = mock('Excel')

      def file.cell(line, column)
        return DateHelper::date_fmt(Date.today) if ['J', 'T'].include?(column)
        return nil if ['C'].include?(column)
        'some text'
      end

      extractor = Proc.new { |column|
        file.cell(1, column)
      }
      expense = block.call(extractor)
      begin
        expense.save!
      rescue
      end
    end

    UploadedExpense.should_receive(:create).with(file_name: "file1")
    UploadedExpense.should_not_receive(:create).with(file_name: "file2")

    importer.load

    Expense.find(:all).count.should == 2
  end
end
