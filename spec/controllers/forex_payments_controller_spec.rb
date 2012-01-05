require 'spec_helper'

describe ForexPaymentsController do

  def valid_attributes
    {}
  end


  describe "GET index" do
    it "assigns all forex_payments as @forex_payments" do
      forex_payments_1 = ForexPayment.create! valid_attributes
      forex_payments_2 = ForexPayment.create! valid_attributes
      get :index, :page => 1, :per_page => 1
      assigns(:forex_payments).should eq([forex_payments_1])
      get :index, :page => 2, :per_page => 1
      assigns(:forex_payments).should eq([forex_payments_2])
    end
  end

  describe "GET Search" do
    it "searches for the given employee id" do
     forex_payments_1 = ForexPayment.create!(emp_id: 10001)
     forex_payments_2 = ForexPayment.create!(emp_id: 10002)
     get :search, :emp_id => 10001
     assigns(:forex_payments).should eq([forex_payments_1])
    end
  end

end
