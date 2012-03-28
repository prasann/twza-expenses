class ForexReportsController < ApplicationController
  include ExcelDataExporter

  HEADERS = [
    'Month', 'EMP ID', 'Employee\'s Name', 'Forex Amt', 'Fx Crrn', 'Travelled Date', 'Place', 'Project',
    'Vendor Name', 'Card No', 'Exp Date', 'Office', 'INR'
  ]

  def index
    @forex_payments = get_results.page(params[:page])
  end

  def export
    export_xls(get_results, HEADERS, :model => ForexPayment)
  end

  private
  def get_results
    res = ForexPayment.where(:issue_date.gte => params[:reports_from]).and(:issue_date.lte => params[:reports_till])
    res = res.and(:currency => params[:forex_payment_currency]) unless params[:forex_payment_currency].blank?
    res = res.and(:vendor_name => params[:forex_payment_vendor_name]) unless params[:forex_payment_vendor_name].blank?
    res = res.and(:office => params[:forex_payment_office]) unless params[:forex_payment_office].blank?
    res
  end
end
