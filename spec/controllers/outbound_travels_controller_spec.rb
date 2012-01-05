require 'spec_helper'

describe OutboundTravelsController do

  def valid_attributes
    {}
  end

  describe "GET index" do
    it "assigns all outbound_travels as @outbound_travels" do
      outbound_travel_1 = OutboundTravel.create! valid_attributes
      outbound_travel_2 = OutboundTravel.create! valid_attributes
      get :index, :page => 1, :per_page => 1
      assigns(:outbound_travels).should eq([outbound_travel_1])
      get :index, :page => 2, :per_page => 1
      assigns(:outbound_travels).should eq([outbound_travel_2])
    end
  end

  describe "GET show" do
    it "assigns the requested outbound_travel as @outbound_travel" do
      outbound_travel = OutboundTravel.create! valid_attributes
      get :show, :id => outbound_travel.id
      assigns(:outbound_travel).should eq(outbound_travel)
    end
  end

  describe "GET new" do
    it "assigns a new outbound_travel as @outbound_travel" do
      get :new
      assigns(:outbound_travel).should be_a_new(OutboundTravel)
    end
  end

  describe "GET edit" do
    it "assigns the requested outbound_travel as @outbound_travel" do
      outbound_travel = OutboundTravel.create! valid_attributes
      get :edit, :id => outbound_travel.id
      assigns(:outbound_travel).should eq(outbound_travel)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new OutboundTravel" do
        expect {
          post :create, :outbound_travel => valid_attributes
        }.to change(OutboundTravel, :count).by(1)
      end

      it "assigns a newly created outbound_travel as @outbound_travel" do
        post :create, :outbound_travel => valid_attributes
        assigns(:outbound_travel).should be_a(OutboundTravel)
        assigns(:outbound_travel).should be_persisted
      end

      it "redirects to the created outbound_travel" do
        post :create, :outbound_travel => valid_attributes
        response.should redirect_to(OutboundTravel.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved outbound_travel as @outbound_travel" do
        OutboundTravel.any_instance.stub(:save).and_return(false)
        post :create, :outbound_travel => {}
        assigns(:outbound_travel).should be_a_new(OutboundTravel)
      end

      it "re-renders the 'new' template" do
        OutboundTravel.any_instance.stub(:save).and_return(false)
        post :create, :outbound_travel => {}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested outbound_travel" do
        outbound_travel = OutboundTravel.create! valid_attributes
        OutboundTravel.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => outbound_travel.id, :outbound_travel => {'these' => 'params'}
      end

      it "assigns the requested outbound_travel as @outbound_travel" do
        outbound_travel = OutboundTravel.create! valid_attributes
        put :update, :id => outbound_travel.id, :outbound_travel => valid_attributes
        assigns(:outbound_travel).should eq(outbound_travel)
      end

      it "redirects to the outbound_travel" do
        outbound_travel = OutboundTravel.create! valid_attributes
        put :update, :id => outbound_travel.id, :outbound_travel => valid_attributes
        response.should redirect_to(outbound_travel)
      end
    end

    describe "with invalid params" do
      it "assigns the outbound_travel as @outbound_travel" do
        outbound_travel = OutboundTravel.create! valid_attributes
        OutboundTravel.any_instance.stub(:save).and_return(false)
        put :update, :id => outbound_travel.id, :outbound_travel => {}
        assigns(:outbound_travel).should eq(outbound_travel)
      end

      it "re-renders the 'edit' template" do
        outbound_travel = OutboundTravel.create! valid_attributes
        OutboundTravel.any_instance.stub(:save).and_return(false)
        put :update, :id => outbound_travel.id, :outbound_travel => {}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested outbound_travel" do
      outbound_travel = OutboundTravel.create! valid_attributes
      expect {
        delete :destroy, :id => outbound_travel.id
      }.to change(OutboundTravel, :count).by(-1)
    end

    it "redirects to the outbound_travels list" do
      outbound_travel = OutboundTravel.create! valid_attributes
      delete :destroy, :id => outbound_travel.id
      response.should redirect_to(outbound_travels_url)
    end
  end

  describe "GET Search" do
    it "searches for the given emp_id" do
      outbound_travel_1 = OutboundTravel.create!(emp_id: 1001)
      outbound_travel_2 = OutboundTravel.create!(emp_id: 1002)
      get :search, :emp_id => 1001
      assigns(:outbound_travels).should eq([outbound_travel_1])
    end
  end

end
