require 'spec_helper'

describe OutboundTravelsController do

  def valid_attributes
    {:emp_id => '123', :emp_name => 'test', :departure_date => Time.now, :expected_return_date => Time.now + 2}
  end

  describe "GET index" do
    it "assigns all outbound_travels as @outbound_travels" do
      outbound_travel_1 = OutboundTravel.create! (valid_attributes.merge!({departure_date: Time.now + 3}))
      outbound_travel_2 = OutboundTravel.create! (valid_attributes.merge!({departure_date: Time.now - 3}))
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
      outbound_travel_1 = OutboundTravel.create!(valid_attributes.merge!({emp_id: 1001}))
      outbound_travel_2 = OutboundTravel.create!(valid_attributes.merge!({emp_id: 1002}))
      get :search, :emp_id => 1001
      assigns(:outbound_travels).to_a.should == [outbound_travel_1]
    end

    it "searches all outbound travels greater than departure date" do
      now = Time.now
      tomorrow = Time.now + 1.day
      outbound_travel_1 = OutboundTravel.create!(valid_attributes.merge!({emp_id: 1001, departure_date: now}))
      outbound_travel_2 = OutboundTravel.create!(valid_attributes.merge!({emp_id: 1001, departure_date: tomorrow}))
      get :search, :departure_date => Date.today + 1
      assigns(:outbound_travels).to_a.should == [outbound_travel_2]
    end
    it "should do an and search if departure date and emp id" do
      now = Time.now
      tomorrow = Time.now + 1.day
      outbound_travel_1_now = OutboundTravel.create!(valid_attributes.merge!({emp_id: 1001, departure_date: now}))
      outbound_travel_1_tomorrow = OutboundTravel.create!(valid_attributes.merge!({emp_id: 1001, departure_date: tomorrow}))
      outbound_travel_2 = OutboundTravel.create!(valid_attributes.merge!({emp_id: 1002, departure_date: tomorrow}))
      get :search, :emp_id => 1001, :departure_date => Date.today + 1
      assigns(:outbound_travels).to_a.should == [outbound_travel_1_tomorrow]
    end

  end

  # describe "GET export" do
  #   it "should return an excel dump of all the outbound travel data" do
  #     declared_fields = [:emp_id, :emp_name, :place, :departure_date, :expected_return_date]
  #     controller.should_receive(:declared_fields).with(OutboundTravel).and_return(declared_fields)
  #     xls_options = {:columns => declared_fields, :headers => OutboundTravelsController::HEADERS}
  #     Time.stub(:now).and_return(Time.parse('2011-10-01'))
  #     file_options = {:filename => OutboundTravel.to_s+'_01-Oct-2011'+ExcelDataExporter::FILE_EXTENSION}
  #     controller.should_receive(:send_data).with(OutboundTravel.all.to_xls(xls_options), file_options)
  #     get :export, :format=>:xls
  #     Mime::XLS.to_sym.should==:xls
  #     Mime::XLS.to_s.should == 'application/vnd.ms-excel'
  #     response.headers["Content-Type"].should == "application/vnd.ms-excel; charset=utf-8"
  #     response.headers["Cache-Control"].should == "no-cache, no-store, max-age=0, must-revalidate"
  #   end
  # end

  describe "GET populate autosuggest data" do
    it "should populate unique and non nullable data for auto suggestion" do
      outbound_travel_1 = OutboundTravel.create!(valid_attributes.merge!({place: 'US', project: 'TWORKS'}))
      outbound_travel_2 = OutboundTravel.create!(valid_attributes.merge!({place: 'US', payroll_effect: '100%', project: 'TWORKS'}))     
      get :data_to_suggest
      assigns(:fields).should be_eql ({'place' => ["US"], 'payroll_effect' => ['100%'], 'project' => ['TWORKS']})
    end
  end  
end
