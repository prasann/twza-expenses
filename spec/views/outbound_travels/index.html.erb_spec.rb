require 'spec_helper'

describe "outbound_travels/index.html.erb" do
  before(:each) do
    assign(:outbound_travels, OutboundTravel.page(1))
  end

  it "renders a list of outbound_travels" do
    render
  end
end
