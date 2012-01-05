class ForexPaymentsController < ApplicationController

  def index
    default_per_page = params[:per_page] || 20
    @forex_payments = ForexPayment.page(params[:page]).per(default_per_page)
  end

  def search
    @forex_payments = ForexPayment.page(params[:page]).where(emp_id: params[:emp_id])
    render :index
  end

end
