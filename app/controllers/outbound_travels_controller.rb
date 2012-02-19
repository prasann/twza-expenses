class OutboundTravelsController < ApplicationController
  include ExcelDataExporter

  HEADERS = [
    'PSID', 'Employee Name', 'Country of visit', 'Duration of Stay (apprx)',
    'Payroll effect in India', 'Departure date from India',
    'Foreign country payroll transfer date',
    'Return date to India', 'Payroll transfer date to India',
    'Expected return date', 'Project Code', 'Comment', 'Actions'
  ]

  def index
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

  # TODO: Shouldnt this be merged in 'index' - search/filter/index are synonymous in REST
  def search
    criteria = {}
    criteria.merge!({:emp_id => params[:emp_id].to_i}) unless params[:emp_id].blank?
    criteria.merge!({:departure_date.gte => params[:departure_date].try(:to_time)}) unless params[:departure_date].blank?
    @outbound_travels = OutboundTravel.page(params[:page]).all_of(criteria)
    render :index, :layout => 'tabs'
  end

  def export
    export_xls(OutboundTravel.all, HEADERS, :model => OutboundTravel)
  end

  def data_to_suggest
    # TODO: Why not send as json?
    render :text => OutboundTravel.get_json_to_populate('place', 'payroll_effect', 'project').to_json
  end

  def update_field
    @outbound_travel = OutboundTravel.find(params[:id])
    # TODO: What if this fails?
    @outbound_travel.update_attributes(params[:name] => params[:value])
    render :nothing => true
  end

  def get_recent
    # TODO: What logic is this?
    @outbound_travels = OutboundTravel.where(:comments => nil).page(params[:page])
    render :index, :layout => 'tabs'
  end

  # TODO: Shouldnt this be merged in 'index' - search/filter/index are synonymous in REST
  def travels_without_return_date
    @outbound_travels = OutboundTravel.where(:return_date => nil).page(params[:page])
    render :index, :layout => 'tabs'
  end
end
