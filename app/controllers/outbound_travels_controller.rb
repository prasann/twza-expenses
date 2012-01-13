require 'csv'
require "#{Rails.root}/lib/helpers/excel_data_exporter"

class OutboundTravelsController < ApplicationController
  include ExcelDataExporter

  HEADERS = [
    '#', 'PSID', 'Employee Name', 'Country of visit', 'Duration of Stay (apprx)',
    'Payroll effect in India', 'Departure date from India',
    'Foreign country payroll transfer date',
    'Return date to India', 'Payroll transfer date to India',
    'Expected return date', 'Project Code', 'Comment', 'Actions'
  ]

  def index
    default_per_page = params[:per_page] || 20
    @outbound_travels = OutboundTravel.desc(:departure_date).page(params[:page]).per(default_per_page)
    render :layout => 'tabs'
  end

  def show
    @outbound_travel = OutboundTravel.find(params[:id])
  end

  def new
    @outbound_travel = OutboundTravel.new
  end

  def edit
    @outbound_travel = OutboundTravel.find(params[:id])
  end

  def create
    @outbound_travel = OutboundTravel.new(params[:outbound_travel])
    if @outbound_travel.save
      redirect_to @outbound_travel, notice: 'Outbound travel was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    @outbound_travel = OutboundTravel.find(params[:id])
    if @outbound_travel.update_attributes(params[:outbound_travel])
      redirect_to @outbound_travel, notice: 'Outbound travel was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @outbound_travel = OutboundTravel.find(params[:id])
    @outbound_travel.destroy
    redirect_to outbound_travels_url
  end

  def search
    @outbound_travels = OutboundTravel.page(params[:page]).any_of({emp_id: params[:emp_id].to_i}, {emp_name: params[:name]})
    render :index, :layout => 'tabs'
  end

  def export
    @data_to_export = OutboundTravel.all
    @file_headers = HEADERS
    @file_name = 'Outbound_Travel'
    @model = OutboundTravel
    @serial_number_column_needed = true

    export_data

    flash[:notice] = "Outbound Travel data export complete!"
  end

  def data_to_suggest
    @outbound_travels = OutboundTravel.all
    create_hash_field('place','payroll_effect');
    render :text => @fields.to_json
  end

  private
  def create_hash_field(*args)
    @fields = Hash.new
    args.each do |field_name|
      @fields[field_name] = @outbound_travels.collect{|x| x[field_name]}.uniq.delete_if{|x| x.nil?}
    end
  end  
end
