require 'spec_helper'

describe "outbound_travels/edit.html.erb" do
  before(:each) do
    @outbound_travel = assign(:outbound_travel, stub_model(OutboundTravel))
  end

  it "renders the edit outbound_travel form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => outbound_travels_path(@outbound_travel), :method => "post" do
    end
  end
end
