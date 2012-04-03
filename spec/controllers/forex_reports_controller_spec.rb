require 'spec_helper'

describe ForexReportsController do
  describe 'GET search' do
    it 'should search forex payments for given params' do
      forex_payments_1 = FactoryGirl.create(:forex_payment, :vendor_name => 'A', :currency => 'USD', :issue_date => DateHelper.date_from_str('31-12-2011'))
      forex_payments_2 = FactoryGirl.create(:forex_payment, :vendor_name => 'B', :currency => 'USD', :issue_date => DateHelper.date_from_str('31-12-2011'))
      forex_payments_3 = FactoryGirl.create(:forex_payment, :vendor_name => 'B', :currency => 'EUR', :issue_date => DateHelper.date_from_str('31-12-2011'))

      get :index, :forex_payment_currency => 'USD', :reports_from => DateHelper.date_from_str('1-12-2011'), :reports_till => DateHelper.date_from_str('31-12-2011'), :forex_payment_vendor_name => 'A'
      assigns(:forex_payments).should eq([forex_payments_1])

      get :index, :forex_payment_currency => 'USD', :reports_from => DateHelper.date_from_str('1-12-2011'), :reports_till => DateHelper.date_from_str('30-12-2011'), :forex_payment_vendor_name => 'A'
      assigns(:forex_payments).should eq([])

      get :index, :forex_payment_currency => 'EUR', :reports_from => DateHelper.date_from_str('1-12-2011'), :reports_till => DateHelper.date_from_str('31-12-2011'), :forex_payment_vendor_name => 'B'
      assigns(:forex_payments).should eq([forex_payments_3])
    end
  end
end
