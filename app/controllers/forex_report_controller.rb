require 'mongoid'
class ForexReportController < ApplicationController
  include ExcelDataExporter

  HEADERS = [
    'Sl.No','Month','EMP ID','Employee\'s Name','Forex Amt','Fx Crrn','Travelled Date','Place','Project',
    'Vendor Name','Card No','Exp Date','Office','INR'
  ]

  def search
    @forex_payments = get_results.page(params[:page])
    render action: 'index'
  end

  def export
    @data_to_export = get_results
    @file_headers = HEADERS
    @file_name = 'Forex Details'
    @model = ForexPayment
    @serial_number_column_needed = true
    export_data
  end

  private
  def get_results
  	return ForexPayment.where(currency: params[:forex_payment_currency])
    .and("issue_date" => {"$gte" => params[:reports_from], "$lte" => params[:reports_till]})
    .and(vendor_name:params[:forex_payment_vendor_name])
  end
end
