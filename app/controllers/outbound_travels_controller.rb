class OutboundTravelsController < ApplicationController
  # GET /outbound_travels
  # GET /outbound_travels.json
  def index
    @outbound_travels = OutboundTravel.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @outbound_travels }
    end
  end

  # GET /outbound_travels/1
  # GET /outbound_travels/1.json
  def show
    @outbound_travel = OutboundTravel.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @outbound_travel }
    end
  end

  # GET /outbound_travels/new
  # GET /outbound_travels/new.json
  def new
    @outbound_travel = OutboundTravel.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @outbound_travel }
    end
  end

  # GET /outbound_travels/1/edit
  def edit
    @outbound_travel = OutboundTravel.find(params[:id])
  end

  # POST /outbound_travels
  # POST /outbound_travels.json
  def create
    @outbound_travel = OutboundTravel.new(params[:outbound_travel])

    respond_to do |format|
      if @outbound_travel.save
        format.html { redirect_to @outbound_travel, notice: 'Outbound travel was successfully created.' }
        format.json { render json: @outbound_travel, status: :created, location: @outbound_travel }
      else
        format.html { render action: "new" }
        format.json { render json: @outbound_travel.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /outbound_travels/1
  # PUT /outbound_travels/1.json
  def update
    @outbound_travel = OutboundTravel.find(params[:id])

    respond_to do |format|
      if @outbound_travel.update_attributes(params[:outbound_travel])
        format.html { redirect_to @outbound_travel, notice: 'Outbound travel was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @outbound_travel.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /outbound_travels/1
  # DELETE /outbound_travels/1.json
  def destroy
    @outbound_travel = OutboundTravel.find(params[:id])
    @outbound_travel.destroy

    respond_to do |format|
      format.html { redirect_to outbound_travels_url }
      format.json { head :ok }
    end
  end
end
