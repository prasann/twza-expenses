require 'spec_helper'

describe TravelDataImporter do
  before(:each) do
    @expected_date = Date.today
    @expected_text_value = "some text"
  end

  it "should read the travel details from the spreadsheet and load the details into the database" do
    OutboundTravel.delete_all
    importer = TravelDataImporter.new

    importer.stub!(:read_from_excel).and_return do |filename, sheetno, block|
      file = mock(Excel)

      def file.cell(line, column)
        return 12345 if ['B'].include?(column)
        return Date.today if ['G'].include?(column)
        return Date.today+100.days if ['I'].include?(column)
        'some text'
      end

      1.upto(2) do |line|
        extractor = Proc.new { |column|
          file.cell(line, column)
        }

        outbound_travel = block.call(extractor)
        outbound_travel.save!
      end
    end

    importer.import('somefile')

    OutboundTravel.find(:all).count.should == 2
    validate_saved_travel_details(OutboundTravel.find(:all).first, 12345, Date.today+100.days)
  end

  it "should not save the invalid forex payment record" do
    OutboundTravel.delete_all
    importer = TravelDataImporter.new
    importer.stub!(:read_from_excel).and_return do |filename, sheetno, block|
      file = mock(Excel)

      def file.cell(line, column)
        return "wrong data" if line == 2
        return 12345 if ['B'].include?(column)
        return Date.today if ['G'].include?(column)
        return Date.today+100.days if ['I'].include?(column)
        'some text'
      end

      1.upto(2) do |line|
        extractor = Proc.new { |column|
          file.cell(line, column)
        }
        outbound_travel = block.call(extractor)
        begin
          outbound_travel.save!
        rescue
          verify_error(outbound_travel.errors.messages)
        end
      end
    end

    importer.import('somefile')

    OutboundTravel.find(:all).count.should == 1
    validate_saved_travel_details(OutboundTravel.find(:all).first, 12345, Date.today+100.days)
  end

  def verify_error(messages)
    messages.size.should == 1
    messages[:departure_date].should == ["can't be blank"]
  end

  def validate_saved_travel_details(travel, emp_id,return_date)
    travel.emp_id.should == emp_id
    travel.emp_name.should ==  @expected_text_value
    travel.place.should == @expected_text_value
    travel.departure_date.should == @expected_date
    travel.return_date.should == return_date
    travel.expected_return_date.should == @expected_text_value
    travel.travel_duration.should == @expected_text_value
    travel.payroll_effect.should == @expected_text_value
    travel.foreign_payroll_transfer.should == @expected_text_value
    travel.return_payroll_transfer.should == @expected_text_value
    travel.project.should == @expected_text_value
    travel.comments.should == @expected_text_value
    travel.actions.should == @expected_text_value
  end

end
