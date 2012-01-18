require 'mongoid'
require "#{Rails.root}/lib/helpers/excel_data_exporter"

class ForexReportsController < ApplicationController
  include ExcelDataExporter
  
  HEADERS = [
    'Month','EMP ID','Employee\'s Name','Forex Amt','Fx Crrn','Travelled Date','Place','Project',
    'Vendor Name','Card No','Exp Date','Office','INR'
  ]

  def search
    @forex_payments = get_results.page(params[:page])
    render action: 'index'
  end

  def export
    export_xls(ForexPayment,HEADERS)
  end

  private
  def get_results
  	return ForexPayment.where(currency: params[:forex_payment_currency])
    .and("issue_date" => {"$gte" => params[:reports_from], "$lte" => params[:reports_till]})
    .and(vendor_name:params[:forex_payment_vendor_name])
  end
end
