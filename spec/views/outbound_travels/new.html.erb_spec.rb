require 'spec_helper'

describe "outbound_travels/new.html.erb" do
  before(:each) do
    assign(:outbound_travel, stub_model(OutboundTravel).as_new_record)
  end

  it "renders new outbound_travel form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => outbound_travels_path, :method => "post" do
    end
  end
end
