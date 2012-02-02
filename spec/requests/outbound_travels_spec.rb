require 'spec_helper'

describe "OutboundTravels" do
  describe "GET /outbound_travels" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get outbound_travels_path
      response.should be_success
    end
  end
end
