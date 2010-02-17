class DomainsController < ApplicationController
  before_filter :authenticate

  # GET /domains
  # GET /domains.xml
  def index
    @domains = @logged_user.domains

    @subdomains_count = 0
    @logged_user.domains.each do |dom|
      @subdomains_count += dom.subdomains.count
    end

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /domains/1
  # GET /domains/1.xml
  def show
    @domain = Domain.find(params[:id])

    respond_to do |format|
      if !@domain or @domain.user == @logged_user
        format.html
      else
        flash[:error] = "Invalid domain"
        format.html { redirect_to :controller => 'domains' }
      end
    end
  end

  # GET /domains/new
  # GET /domains/new.xml
  def new
    @domain = Domain.new
    @user = @logged_user

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @domain }
    end
  end

  # POST /domains
  # POST /domains.xml
  def create
    @domain = Domain.new(params[:domain])
    @domain.user = @logged_user

    respond_to do |format|
      if @domain.save
        # Create main WWW subdomain
        @subdomain = Subdomain.new()
        @subdomain.url = "www"
        @subdomain.domain = @domain
        @subdomain.path = "www"
        @subdomain.mainsub = true

        if @subdomain.save
          flash[:notice] = 'Domain was successfully added.'
          format.html { redirect_to :controller => 'domains' }
        end
      else
        flash[:error] = 'Error adding domain.'
        format.html { redirect_to :controller => 'domains' }
      end
    end
  end

  # DELETE /domains/1
  # DELETE /domains/1.xml
  def destroy
    @domain = Domain.find(params[:id])
    @domain.subdomains.each do |sub|
      sub.destroy
    end

    @domain.destroy

    respond_to do |format|
      format.html { redirect_to :controller => 'domains' }
    end
  end

  def addservice
    @domain = Domain.find(params[:domain_id])
    @service = Service.find(params[:service_id])
    @domain.services << @service

    if @domain.save
      flash[:notice] = 'Service successfully added'
      redirect_to :controller => ("service_" + @service.name), :action => "addtodomain"
    else
      flash[:notice] = 'Error occured'
      redirect_to :controller => "domains"
    end
  end
end

