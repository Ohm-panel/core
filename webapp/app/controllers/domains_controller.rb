# Domains controller
class DomainsController < ApplicationController
  before_filter :authenticate

  # GET /domains
  # GET /domains.xml
  def index
    @domains = @logged_user.domains

    respond_to do |format|
      format.html # index.html.erb
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
          flash[:notice] = "Domain was successfully added.#{@@changes}"
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
    if @domain.user == @logged_user
      @domain.subdomains.each do |sub|
        sub.destroy
      end
      @domain.destroy
      flash[:notice] = "Domain was successfully deleted.#{@@changes}"
    else
      flash[:error] = "Invalid domain"
    end
    redirect_to :controller => 'domains'
  end

  def addservice
    @domain = Domain.find(params[:domain_id])
    @service = Service.find(params[:service_id][0])

    if @domain.user == @logged_user and @service.users.include? @logged_user and @service.by_domain
      @domain.services << @service

      if @domain.save
        flash[:notice] = 'Service successfully added'
        redirect_to :controller => (@service.controller), :action => "addtodomain", :domain_id => @domain.id, :service_id => @service.id
      else
        flash[:error] = 'Error occured'
        redirect_to :controller => 'domains'
      end
    else
      flash[:error] = "Invalid domain or service"
      redirect_to :controller => 'domains'
    end
  end
end

