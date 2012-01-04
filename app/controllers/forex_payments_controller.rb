class ForexPaymentsController < ApplicationController

  def index
    @forex_payments = ForexPayment.where(emp_id: params[:emp_id])
  end

end