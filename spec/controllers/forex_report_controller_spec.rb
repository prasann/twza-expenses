require 'spec_helper'

describe ForexReportController do

  def valid_attributes
    {:emp_id => '123', :emp_name => 'test', :amount => 120.25, :currency => 'INR', :travel_date => Date.today,
    :office => 'Chennai', :inr => 5001.50}
  end

  describe 'GET  search' do
    it 'should search forex payments for given params' do
      forex_payments_1 = ForexPayment.create!(valid_attributes.merge!(vendor_name: 'A', currency: 'USD', issue_date: Date.parse('31-12-2011')))
      forex_payments_2 = ForexPayment.create!(valid_attributes.merge!(vendor_name: 'B', currency: 'USD', issue_date: Date.parse('31-12-2011')))
      forex_payments_3 = ForexPayment.create!(valid_attributes.merge!(vendor_name: 'B', currency: 'EUR',issue_date: Date.parse('31-12-2011')))

      get :search, :forex_payment_currency => 'USD', :reports_from => Date.parse('1-12-2011'), :reports_till => Date.parse('31-12-2011'), :forex_payment_vendor_name => 'A'
      assigns(:forex_payments).should eq([forex_payments_1])	

      get :search, :forex_payment_currency => 'USD', :reports_from => Date.parse('1-12-2011'), :reports_till => Date.parse('30-12-2011'), :forex_payment_vendor_name => 'A'
      assigns(:forex_payments).should eq([])

      get :search, :forex_payment_currency => 'EUR', :reports_from => Date.parse('1-12-2011'), :reports_till => Date.parse('31-12-2011'), :forex_payment_vendor_name => 'B'
      assigns(:forex_payments).should eq([forex_payments_3])
    end
  end
end
