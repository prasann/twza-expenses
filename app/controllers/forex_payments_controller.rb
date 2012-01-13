require 'csv'
require "#{Rails.root}/lib/helpers/excel_data_exporter"

class ForexPaymentsController < ApplicationController
  include ExcelDataExporter

  HEADERS = [
      'Sl.No','Month','EMP ID','Employee\'s Name','Forex Amt','Fx Crrn','Travelled Date','Place','Project',
      'Vendor Name','Card No','Exp Date','Office','INR'
  ]

  def index
    default_per_page = params[:per_page] || 20
    @forex_payments = ForexPayment.desc(:travel_date).page(params[:page]).per(default_per_page)
    render :layout => 'tabs'
  end

  def show
    @forex_payment = ForexPayment.find(params[:id])
    render 
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
    redirect_to forex_payments_url
  end

  def search
    @forex_payments = ForexPayment.page(params[:page]).any_of({emp_id: params[:emp_id].to_i}, {emp_name: params[:name]})
    render :index, :layout => 'tabs'
  end

  def export
    @data_to_export = ForexPayment.all
    @file_headers = HEADERS
    @file_name = 'Forex Details'
    @model = ForexPayment
    @serial_number_column_needed = true

    export_data
  end

  def data_to_suggest
    @forex_payments = ForexPayment.all
    create_hash_field('currency','vendor_name','place');
    render :text => @fields.to_json
  end

  private
  def create_hash_field(*args)
    @fields = Hash.new
    args.each do |field_name|
      @fields[field_name] = @forex_payments.collect{|x| x[field_name]}.uniq.delete_if{|x| x.nil?}
    end
  end  
end
