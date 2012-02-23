class ForexPaymentsController < ApplicationController
  include ExcelDataExporter

  HEADERS = [
    'Month', 'EMP ID', 'Employee\'s Name', 'Forex Amt', 'Fx Crrn', 'Travelled Date', 'Place', 'Project',
    'Vendor Name', 'Card No', 'Exp Date', 'Office', 'INR'
  ]

  def index
    criteria = !params[:empl_id].blank? ? ExpenseSettlement.for_empl_id(params[:emp_id]) : ExpenseSettlement
    @forex_ids_with_settlement = criteria.all.collect(&:forex_payments)
    @forex_payments = ForexPayment.desc(:travel_date).page(params[:page]).per(default_per_page)
    render :layout => 'tabs'
  end

  def show
    @forex_payment = ForexPayment.find(params[:id])
  end

  def new
    @forex_payment = ForexPayment.new
  end

  def edit
    @forex_payment = ForexPayment.find(params[:id])
  end

  def create
    @forex_payment = ForexPayment.new(params[:forex_payment])
    if @forex_payment.save
      redirect_to @forex_payment, notice: 'Forex payment options are successfully created.'
    else
      render action: "new"
    end
  end

  def update
    @forex_payment = ForexPayment.find(params[:id])
    if @forex_payment.update_attributes(params[:forex_payment])
      redirect_to @forex_payment, notice: 'Forex payment options are successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @forex_payment = ForexPayment.find(params[:id])
    @forex_payment.destroy
    redirect_to forex_payments_path
  end

  # TODO: Shouldnt this be merged in 'index' - search/filter/index are synonymous in REST
  def search
    @forex_ids_with_settlement = ExpenseSettlement.for_empl_id(params[:emp_id]).collect(&:forex_payments).flatten
    @forex_payments = ForexPayment.page(params[:page]).any_of({emp_id: params[:emp_id].to_i}, {emp_name: params[:name]})
    render :index, :layout => 'tabs'
  end

  def export
    export_xls(ForexPayment.all, HEADERS, :model => ForexPayment)
  end

  def data_to_suggest
    # TODO: Why not send as json?
    render :text => ForexPayment.get_json_to_populate('currency', 'vendor_name', 'place', 'office').to_json
  end
end
