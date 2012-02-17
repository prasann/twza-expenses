require 'spec_helper'

describe ForexPaymentsController do
  describe "GET index" do
    it "assigns all forex_payments as @forex_payments" do
      forex_payments_1 = Factory(:forex_payment, :travel_date => Time.now + 3)
      forex_payments_2 = Factory(:forex_payment, :travel_date => Time.now - 3)

      get :index, :page => 1, :per_page => 1

      assigns(:forex_payments).should eq([forex_payments_1])

      get :index, :page => 2, :per_page => 1
      assigns(:forex_payments).should eq([forex_payments_2])
    end
  end

  describe "GET show" do
    it "assigns the requested forex_payment as @forex_payment" do
      forex_payment = Factory(:forex_payment)

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
      forex_payment = Factory(:forex_payment)

      get :edit, :id => forex_payment.id

      assigns(:forex_payment).should eq(forex_payment)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new ForexPayment" do
        expect {
          post :create, :forex_payment => Factory.attributes_for(:forex_payment)
        }.to change(ForexPayment, :count).by(1)
      end

      it "assigns a newly created forex_payment as @forex_payment" do
        post :create, :forex_payment => Factory.attributes_for(:forex_payment)

        assigns(:forex_payment).should be_a(ForexPayment)
        assigns(:forex_payment).should be_persisted
      end

      it "redirects to the created forex_payment" do
        post :create, :forex_payment => Factory.attributes_for(:forex_payment)

        response.should redirect_to(ForexPayment.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved forex_payment as @forex_payment" do
        ForexPayment.any_instance.stub(:save).and_return(false)

        post :create, :forex_payment => {}

        assigns(:forex_payment).should be_a_new(ForexPayment)
      end

      it "re-renders the 'new' template on error" do
        ForexPayment.any_instance.stub(:save).and_return(false)

        post :create, :forex_payment => {}

        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested forex_payment" do
        forex_payment = Factory(:forex_payment)

        ForexPayment.any_instance.should_receive(:update_attributes).with({'these' => 'params'})

        put :update, :id => forex_payment.id, :forex_payment => {'these' => 'params'}
      end

      it "assigns the requested forex_payment as @forex_payment" do
        forex_payment = Factory(:forex_payment)

        put :update, :id => forex_payment.id, :forex_payment => Factory.attributes_for(:forex_payment)

        assigns(:forex_payment).should eq(forex_payment)
      end

      it "redirects to the forex_payment" do
        forex_payment = Factory(:forex_payment)

        put :update, :id => forex_payment.id, :forex_payment => Factory.attributes_for(:forex_payment)

        response.should redirect_to(forex_payment)
      end
    end

    describe "with invalid params" do
      it "assigns the forex_payment as @forex_payment" do
        forex_payment = Factory(:forex_payment)
        ForexPayment.any_instance.stub(:save).and_return(false)

        put :update, :id => forex_payment.id, :forex_payment => {}

        assigns(:forex_payment).should eq(forex_payment)
      end

      it "re-renders the 'edit' template" do
        forex_payment = Factory(:forex_payment)
        ForexPayment.any_instance.stub(:save).and_return(false)

        put :update, :id => forex_payment.id, :forex_payment => {}

        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested forex_payment" do
      forex_payment = Factory(:forex_payment)
      expect {
        delete :destroy, :id => forex_payment.id
      }.to change(ForexPayment, :count).by(-1)
    end

    it "redirects to the forex_payments list" do
      forex_payment = Factory(:forex_payment)

      delete :destroy, :id => forex_payment.id

      response.should redirect_to(forex_payments_url)
    end
  end

  describe "GET Search" do
    it "searches for the given employee id" do
      forex_payments_1 = Factory(:forex_payment, :emp_id => 10001)
      forex_payments_2 = Factory(:forex_payment, :emp_id => 10001)
      expense = Expense.create()
      outbound_travel = OutboundTravel.create(:emp_id => '123', :emp_name => 'test', :place => 'US',:departure_date => Time.now)
      expense_settlement = ExpenseSettlement.create!(:empl_id => 10001, :forex_payments => [forex_payments_1[:_id]],
                                                    :expenses => [expense.id],
                                                    :outbound_travel => outbound_travel.id,
                                                    :status => ExpenseSettlement::GENERATED_DRAFT)

      get :search, :emp_id => 10001

      assigns(:forex_payments).should eq([forex_payments_1, forex_payments_2])
      assigns(:forex_ids_with_settlement).size.should == 1
      assigns(:forex_ids_with_settlement).should include(forex_payments_1[:_id])
    end
  end

  # describe "GET export" do
  #    it "should return an excel dump of all the outbound travel data" do
  #     declared_fields = [:emp_id, :emp_name, :currency, :amount, :place, :office, :inr]
  #     controller.should_receive(:declared_fields).with(ForexPayment).and_return(declared_fields)
  #     xls_options = {:columns => declared_fields, :headers => ForexPaymentsController::HEADERS}
  #     Time.stub(:now).and_return(Time.parse('2011-10-01'))
  #     file_options = {:filename => ForexPayment.to_s+'_01-Oct-2011'+ExcelDataExporter::FILE_EXTENSION}
  #     controller.should_receive(:send_data).with(ForexPayment.to_xls(xls_options), file_options)
  #     get :export, :format=>:xls
  #     Mime::XLS.to_sym.should==:xls
  #     Mime::XLS.to_s.should == 'application/vnd.ms-excel'
  #     response.headers["Content-Type"].should == "application/vnd.ms-excel; charset=utf-8"
  #     response.headers["Cache-Control"].should == "no-cache, no-store, max-age=0, must-revalidate"
  #    end
  # end
end
