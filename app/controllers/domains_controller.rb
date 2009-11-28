class DomainsController < ApplicationController
  # GET /domains
  # GET /domains.xml
  def index
    @domains = Domain.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @domains }
    end
  end

  # GET /domains/1
  # GET /domains/1.xml
  def show
    @domain = Domain.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @domain }
    end
  end

  # GET /domains/new
  # GET /domains/new.xml
  def new
    @domain = Domain.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @domain }
    end
  end

  # GET /domains/1/edit
  def edit
    @domain = Domain.find(params[:id])
  end

  # POST /domains
  # POST /domains.xml
  def create
    @domain = Domain.new(params[:domain])

    respond_to do |format|
      if @domain.save
        flash[:notice] = 'Domain was successfully added.'
        format.html { redirect_to(@domain.user) }
      else
        flash[:error] = 'Error adding domain.'
        format.html { redirect_to(@domain.user) }
      end
    end
  end

  # DELETE /domains/1
  # DELETE /domains/1.xml
  def destroy
    @domain = Domain.find(params[:id])
    @domain.destroy

    respond_to do |format|
      format.html { redirect_to(@domain.user) }
    end
  end

  def addservice
    @domain = Domain.find(params[:domain_id])
    @domain.services << Service.find(params[:service_id])

    respond_to do |format|
      if @domain.save
        flash[:notice] = 'Service successfully added'
        format.html { redirect_to :controller => "dashboard" }
      else
        flash[:notice] = 'Error occured'
        format.html { redirect_to :controller => "dashboard" }
      end
    end
  end
end

