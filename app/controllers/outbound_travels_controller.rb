require 'csv'

class OutboundTravelsController < ApplicationController
  HEADERS = ['#', 'PSID', 'Employee Name', 'Country of visit', 'Duration of Stay	(apprx)',
             'Payroll effect in India', 'Departure date from India',
             'Foreign country payroll transfer date',
             'Return date to India', 'Payroll transfer date to India',
             'Expected return date', 'Project Code', 'Comment', 'Actions']

  def index
    default_per_page = params[:per_page] || 20
    @outbound_travels = OutboundTravel.page(params[:page]).per(default_per_page)
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
    @outbound_travels = OutboundTravel.page(params[:page]).where(emp_id: params[:emp_id])
    render :index
  end

  def export
    outbound_travels = OutboundTravel.all

    declared_fields = OutboundTravel.fields.select_map { |field| field[1].name if field[1].name != '_id' && field[1].name != '_type' && field[1].name != 'nil' }

    row = []
    csv_data = CSV.generate do |csv|
      csv << HEADERS
      outbound_travels.each do |outbound_travel|
        csv << declared_fields.collect { |field| ((outbound_travel[field.to_sym]).instance_of? Time) ?
            (outbound_travel[field.to_sym].strftime("%d-%b-%Y"))
        : (outbound_travel[field.to_sym].to_s) }
      end
    end

    file_name = "Outbound_Travel_" + Time.now.strftime("%m-%d-%Y") + ".xls"
    send_data(csv_data, :type=>"application/excel; charset=UTF-8; header-present", :disposition=>'attachment', :filename => file_name)

    flash[:notice] = "Outbound Travel data export complete!"
  end
end
