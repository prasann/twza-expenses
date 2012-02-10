require 'spec_helper'
require 'data_importer/forex_data_importer'


describe ForexDataImporter do

  before(:each) do
    @expected_date = Date.today
    @expected_text_value = "some text"
  end

  xit "should read the forex details from the spreadsheet and load the details into the database" do
    importer = ForexDataImporter.new
    card_number = '1234 1234 1234 1234 Axis'
    card_expiry_date = Date.today + 100
    importer.stub!(:read_from_excel).and_return do |filename, sheetno, block|
      file = mock(Excel)

      def file.cell(line, column)
        return 1 if ['C', 'E', 'N'].include?(column)
        return Date.today if ['B', 'G'].include?(column)
        return card_number if ['K'].include?(column)
        return card_expiry_date if ['L'].include?(column)
        'some text'
      end

      1.upto(2) do |line|
        extractor = Proc.new { |column|
          file.cell(line, column)
        }

        (forex_payment = block.call(extractor))
        puts forex_payment.inspect
        #forex_payment.save
      end
    end


    importer.import('somefile')

    ForexPayment.find(:all).count.should == 2
    forex_payment = ForexPayment.find(:all).first
    validate_saved_forex_details(forex_payment, card_number, card_expiry_date)
  end

  xit "should not save the invalid forex payment record" do
    importer = ForexDataImporter.new
    importer.stub!(:read_from_excel).and_return do |filename, sheetno, block|
      file = mock(Excel)

      def file.cell(line, column)
        return "wrong data" if line == 2
        return 1 if ['C', 'E', 'N'].include?(column)
        return Date.today if ['B', 'G'].include?(column)
        'some text'
      end

      1.upto(2) do |line|
        extractor = Proc.new { |column|
          file.cell(line, column)
        }
        block.call extractor
      end
    end

    importer.import('somefile')

    ForexPayment.find(:all).count.should == 1
    forex_payment = ForexPayment.find(:all).first

    validate_saved_forex_details(forex_payment)


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
