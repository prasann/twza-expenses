class ForexReportsController < ApplicationController
  include ExcelDataExporter

  HEADERS = [
    'Month', 'EMP ID', 'Employee\'s Name', 'Forex Amt', 'Fx Crrn', 'Travelled Date', 'Place', 'Project',
    'Vendor Name', 'Card No', 'Exp Date', 'Office', 'INR'
  ]

  def index
    @forex_payments = get_results.page(params[:page])
    render action: 'index'
  end

  def export
    export_xls(get_results, HEADERS, :model => ForexPayment)
  end

  private
  def get_results
    ForexPayment.where(:currency => regex_if_nil(params[:forex_payment_currency]))
    .and(:issue_date.gte => params[:reports_from]).and(:issue_date.lte => params[:reports_till])
    .and(vendor_name: regex_if_nil(params[:forex_payment_vendor_name]))
    .and(office: regex_if_nil(params[:forex_payment_office]))
  end

  def regex_if_nil(val)
    return val.blank? ? /(\S)*/ : val
  end
end
