class ServicesController < ApplicationController
  before_filter :authenticate_root

  # GET /services
  # GET /services.xml
  def index
    @services = Service.all
  end

  # GET /services/1
  # GET /services/1.xml
  def show
    @service = Service.find(params[:id])
  end

  # GET /services/new
  # GET /services/new.xml
  def new
    @service = Service.new
  end

  # GET /services/1/edit
  def edit
    @service = Service.find(params[:id])
  end

  # POST /services
  # POST /services.xml
  def create
    @service = Service.new(params[:service])

    if @service.save
      flash[:notice] = 'Service was successfully created.'
      redirect_to @service
    else
      render :action => "new"
    end
  end

  # PUT /services/1
  # PUT /services/1.xml
  def update
    @service = Service.find(params[:id])

    if @service.update_attributes(params[:service])
      flash[:notice] = 'Service was successfully updated.'
      redirect_to @service
    else
      render :action => "edit"
    end
  end

  # DELETE /services/1
  # DELETE /services/1.xml
  def destroy
    @service = Service.find(params[:id])
    @service.destroy

    redirect_to services_url
  end
end

