require 'spec_helper'

describe ForexDataImporter do
  before(:each) do
    @expected_date = Date.today
    @expected_text_value = "some text"
  end

  it "should read the forex details from the spreadsheet and load the details into the database" do
    ForexPayment.delete_all
    importer = ForexDataImporter.new

    importer.should_receive(:read_from_excel).and_return do |filename, sheetno, &block|
      file = mock('Excel')

      def file.cell(line, column)
        return 1 if ['C', 'E', 'N'].include?(column)
        return Date.today if ['B', 'G'].include?(column)
        return '1234 1234 1234 1234 Axis' if ['K'].include?(column)
        return '04/15' if ['L'].include?(column)
        'some text'
      end

      1.upto(2) do |line|
        extractor = Proc.new { |column|
          file.cell(line, column)
        }

        forex_payment = block.call(extractor)
        forex_payment.save
      end
    end

    importer.import('somefile')

    ForexPayment.find(:all).count.should == 2
    forex_payment = ForexPayment.find(:all).first
    validate_saved_forex_details(forex_payment, '1234 1234 1234 1234 Axis', Date.strptime('04/15','%m/%y'))
  end

  it "should not save the invalid forex payment record" do
    ForexPayment.delete_all
    importer = ForexDataImporter.new
    importer.should_receive(:read_from_excel).and_return do |filename, sheetno, &block|
      file = mock('Excel')

      def file.cell(line, column)
        return "wrong data" if line == 2
        return 1 if ['C', 'E', 'N'].include?(column)
        return Date.today if ['B', 'G'].include?(column)
        return nil if ['K', 'L'].include?(column)
        'some text'
      end

      1.upto(2) do |line|
        extractor = Proc.new { |column|
          file.cell(line, column)
        }

        forex_payment = block.call(extractor)
        begin
          forex_payment.save!
        rescue
          verify_error forex_payment.errors.messages
        end
      end
    end

    importer.import('somefile')

    ForexPayment.find(:all).count.should == 1
    forex_payment = ForexPayment.find(:all).first
    validate_saved_forex_details(forex_payment)
  end

  def verify_error(messages)
    messages.size.should == 2
    messages[:travel_date].should == ["can't be blank"]
    messages[:issue_date].should == ["can't be blank"]
  end

  def validate_saved_forex_details(forex_payment, card_number=nil, card_expiry_date=nil)
    forex_payment.issue_date.should == @expected_date
    forex_payment.emp_id.should == 1
    forex_payment.amount.should == 1
    forex_payment.currency.should == @expected_text_value
    forex_payment.travel_date.should == @expected_date
    forex_payment.place.should == @expected_text_value
    forex_payment.project.should == @expected_text_value
    forex_payment.vendor_name.should == @expected_text_value
    forex_payment.card_number.should == card_number
    forex_payment.expiry_date.should == card_expiry_date
    forex_payment.office.should == @expected_text_value
    forex_payment.inr.should == 1
  end

end
