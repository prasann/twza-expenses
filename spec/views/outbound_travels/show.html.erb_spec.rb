require 'spec_helper'

describe "outbound_travels/show.html.erb" do
  before(:each) do
    @outbound_travel = assign(:outbound_travel, stub_model(OutboundTravel))
  end

  it "renders attributes in <p>" do
    render
  end
end
