require 'spec_helper'

describe BankDetailsImporter do
  before(:each) do
    @expected_date = Date.today
    @expected_text_value = "some text"
  end

  it "should read the bank details from the spreadsheet and load the details into the database" do
    BankDetail.delete_all
    importer = BankDetailsImporter.new

    importer.stub!(:read_from_excel).and_return do |filename, sheetno, block|
      file = mock('Excel')

      def file.cell(line, column)
        return '12345' if ['B'].include?(column)
        return 'John Smith' if ['C'].include?(column)
        return 42611123423 if ['D'].include?(column)
      end

      extractor = Proc.new { |column| file.cell(1, column) }

      bank_detail = block.call(extractor)
      bank_detail.save
    end

    importer.import('somefile')

    BankDetail.find(:all).count.should == 1
    validate_saved_bank_details(BankDetail.find(:all).first, '12345', 'John Smith', 42611123423)
  end

  it "should not raise validation error if account number is repeated" do
    BankDetail.delete_all
    importer = BankDetailsImporter.new
    importer.stub!(:read_from_excel).and_return do |filename, sheetno, block|
      file = mock('Excel')

      def file.cell(line, column)
        return '12345' if ['B'].include?(column)
        return 'John Smith' if ['C'].include?(column)
        return 42611123423 if ['D'].include?(column)
      end

      1.upto(2) do |line|
        extractor = Proc.new { |column|
          file.cell(line, column)
        }
        bank_detail = block.call(extractor)
        bank_detail.save
        if (line == 2)
          bank_detail.errors.messages.size.should == 1
          bank_detail.errors.messages[:account_no].should eq ['is already taken']
        end
      end
    end

    importer.import('somefile')

    BankDetail.find(:all).count.should == 1
  end

  def validate_saved_bank_details(bank_detail, emp_id, emp_name, bank_account)
    bank_detail.empl_id.should == emp_id
    bank_detail.empl_name.should == emp_name
    bank_detail.account_no.should == bank_account
  end
end
