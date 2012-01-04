require 'spec_helper'

describe "outbound_travels/index.html.erb" do
  before(:each) do
    assign(:outbound_travels, [
      stub_model(OutboundTravel),
      stub_model(OutboundTravel)
    ])
  end

  it "renders a list of outbound_travels" do
    render
  end
end
