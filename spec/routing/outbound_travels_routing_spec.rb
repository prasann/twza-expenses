require "spec_helper"

describe OutboundTravelsController do
  describe "routing" do

    it "routes to #index" do
      get("/outbound_travels").should route_to("outbound_travels#index")
    end

    it "routes to index" do
      get("/outbound_travels/index/1").should route_to("outbound_travels#index", :page => "1")
    end

    it "routes to #new" do
      get("/outbound_travels/new").should route_to("outbound_travels#new")
    end

    it "routes to #show" do
      get("/outbound_travels/1").should route_to("outbound_travels#show", :id => "1")
    end

    it "routes to #edit" do
      get("/outbound_travels/1/edit").should route_to("outbound_travels#edit", :id => "1")
    end

    it "routes to #create" do
      post("/outbound_travels").should route_to("outbound_travels#create")
    end

    it "routes to #update" do
      put("/outbound_travels/1").should route_to("outbound_travels#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/outbound_travels/1").should route_to("outbound_travels#destroy", :id => "1")
    end

  end
end
