class OutboundTravelsController < ApplicationController
  def index
    @outbound_travels = OutboundTravel.all
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
    @outbound_travel.save ? 
        redirect_to @outbound_travel, notice: 'Outbound travel was successfully created.' :
        render action: "new"
  end

  def update
    @outbound_travel = OutboundTravel.find(params[:id])
    @outbound_travel.update_attributes(params[:outbound_travel]) ? 
        redirect_to @outbound_travel, notice: 'Outbound travel was successfully updated.' : 
        render action: "edit"
  end

  def destroy
    @outbound_travel = OutboundTravel.find(params[:id])
    @outbound_travel.destroy
    redirect_to outbound_travels_url
  end
end
