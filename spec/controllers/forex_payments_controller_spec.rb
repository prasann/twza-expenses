require 'spec_helper'

describe ForexPaymentsController do

  def valid_attributes
    {:emp_id => '123', :emp_name => 'test', :amount => 120.25, :currency => 'INR', :travel_date => Date.today,
    :office => 'Chennai', :inr => 5001.50}
  end

  describe "GET index" do
    it "assigns all forex_payments as @forex_payments" do
      forex_payments_1 = ForexPayment.create! (valid_attributes.merge!({travel_date: Time.now + 3}))
      forex_payments_2 = ForexPayment.create! (valid_attributes.merge!({travel_date: Time.now - 3}))
      get :index, :page => 1, :per_page => 1
      assigns(:forex_payments).should eq([forex_payments_1])
      get :index, :page => 2, :per_page => 1
      assigns(:forex_payments).should eq([forex_payments_2])
    end
  end

  describe "GET show" do
    it "assigns the requested forex_payment as @forex_payment" do
      forex_payment = ForexPayment.create! valid_attributes
      get :show, :id => forex_payment.id
      assigns(:forex_payment).should eq(forex_payment)
    end
  end

  describe "GET new" do
    it "assigns a new forex_payment as @forex_payment" do
      get :new
      assigns(:forex_payment).should be_a_new(ForexPayment)
    end
  end

  describe "GET edit" do
    it "assigns the requested forex_payment as @forex_payment" do
      forex_payment = ForexPayment.create! valid_attributes
      get :edit, :id => forex_payment.id
      assigns(:forex_payment).should eq(forex_payment)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new ForexPayment" do
        expect {
          post :create, :forex_payment => valid_attributes
        }.to change(ForexPayment, :count).by(1)
      end

      it "assigns a newly created forex_payment as @forex_payment" do
        post :create, :forex_payment => valid_attributes
        assigns(:forex_payment).should be_a(ForexPayment)
        assigns(:forex_payment).should be_persisted
      end

      it "redirects to the created forex_payment" do
        post :create, :forex_payment => valid_attributes
        response.should redirect_to(ForexPayment.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved forex_payment as @forex_payment" do
        ForexPayment.any_instance.stub(:save).and_return(false)
        post :create, :forex_payment => {}
        assigns(:forex_payment).should be_a_new(ForexPayment)
      end

      it "re-renders the 'new' template" do
        ForexPayment.any_instance.stub(:save).and_return(false)
        post :create, :forex_payment => {}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested forex_payment" do
        forex_payment = ForexPayment.create! valid_attributes
        ForexPayment.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => forex_payment.id, :forex_payment => {'these' => 'params'}
      end

      it "assigns the requested forex_payment as @forex_payment" do
        forex_payment = ForexPayment.create! valid_attributes
        put :update, :id => forex_payment.id, :forex_payment => valid_attributes
        assigns(:forex_payment).should eq(forex_payment)
      end

      it "redirects to the forex_payment" do
        forex_payment = ForexPayment.create! valid_attributes
        put :update, :id => forex_payment.id, :forex_payment => valid_attributes
        response.should redirect_to(forex_payment)
      end
    end

    describe "with invalid params" do
      it "assigns the forex_payment as @forex_payment" do
        forex_payment = ForexPayment.create! valid_attributes
        ForexPayment.any_instance.stub(:save).and_return(false)
        put :update, :id => forex_payment.id, :forex_payment => {}
        assigns(:forex_payment).should eq(forex_payment)
      end

      it "re-renders the 'edit' template" do
        forex_payment = ForexPayment.create! valid_attributes
        ForexPayment.any_instance.stub(:save).and_return(false)
        put :update, :id => forex_payment.id, :forex_payment => {}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested forex_payment" do
      forex_payment = ForexPayment.create! valid_attributes
      expect {
        delete :destroy, :id => forex_payment.id
      }.to change(ForexPayment, :count).by(-1)
    end

    it "redirects to the forex_payments list" do
      forex_payment = ForexPayment.create! valid_attributes
      delete :destroy, :id => forex_payment.id
      response.should redirect_to(forex_payments_url)
    end
  end

  describe "GET Search" do
    it "searches for the given employee id" do
      forex_payments_1 = ForexPayment.create!(valid_attributes.merge!(emp_id: 10001))
      forex_payments_2 = ForexPayment.create!(valid_attributes.merge!(emp_id: 10002))
      get :search, :emp_id => 10001
      assigns(:forex_payments).should eq([forex_payments_1])
    end
  end

  describe "GET export" do
     it "should return an excel dump of all the outbound travel data" do
      declared_fields = [:emp_id, :emp_name, :currency, :amount, :place, :office, :inr]
      controller.should_receive(:declared_fields).with(ForexPayment).and_return(declared_fields)
      xls_options = {:columns => declared_fields, :headers => ForexPaymentsController::HEADERS}
      Time.stub(:now).and_return(Time.parse('2011-10-01'))
      file_options = {:filename => ForexPayment.to_s+'_01-Oct-2011'+ExcelDataExporter::FILE_EXTENSION}
      controller.should_receive(:send_data).with(ForexPayment.all.to_xls(xls_options), file_options)
      get :export, :format=>:xls
      Mime::XLS.to_sym.should==:xls
      Mime::XLS.to_s.should == 'application/vnd.ms-excel'
      response.headers["Content-Type"].should == "application/vnd.ms-excel; charset=utf-8"
      response.headers["Cache-Control"].should == "no-cache, no-store, max-age=0, must-revalidate"
     end
  end

  describe "GET populate autosuggest data" do
    it "should populate unique and non nullable data for auto suggestion" do
      outbound_travel_1 = ForexPayment.create!(valid_attributes.merge!({place: 'US', currency: 'GBP'}))
      outbound_travel_2 = ForexPayment.create!(valid_attributes.merge!({place: 'US', vendor_name: 'VFC', currency: 'USD'}))
      get :data_to_suggest
      assigns(:fields).should be_eql ({'place' => ["US"], 'vendor_name' => ['VFC'], 'currency' => ['GBP','USD']})
    end
  end

end
