class SubdomainsController < ApplicationController
  before_filter :authenticate

  # GET /subdomains
  # GET /subdomains.xml
#  def index
#    @subdomains = Subdomain.all

#    respond_to do |format|
#      format.html # index.html.erb
#      format.xml  { render :xml => @subdomains }
#    end
#  end

  # GET /subdomains/1
  # GET /subdomains/1.xml
#  def show
#    @subdomain = Subdomain.find(params[:id])

#    respond_to do |format|
#      format.html # show.html.erb
#      format.xml  { render :xml => @subdomain }
#    end
#  end

  # GET /subdomains/new
  # GET /subdomains/new.xml
  def new
    @subdomain = Subdomain.new
    @subdomain.domain = Domain.find(params[:domain])
    @domains = @logged_user.domains

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @subdomain }
    end
  end

  # GET /subdomains/1/edit
  def edit
    @subdomain = Subdomain.find(params[:id])
  end

  # POST /subdomains
  # POST /subdomains.xml
  def create
    @subdomain = Subdomain.new(params[:subdomain])

    respond_to do |format|
      if @subdomain.save
        flash[:notice] = 'Subdomain was successfully created.'
        format.html { redirect_to :controller => "dashboard" }
      else
        format.html { redirect_to :controller => "dashboard" }
      end
    end
  end

  # PUT /subdomains/1
  # PUT /subdomains/1.xml
  def update
    @subdomain = Subdomain.find(params[:id])

    respond_to do |format|
      if @subdomain.update_attributes(params[:subdomain])
        flash[:notice] = 'Subdomain was successfully updated.'
        format.html { redirect_to :controller => "dashboard" }
      else
        format.html { redirect_to :controller => "dashboard" }
      end
    end
  end

  # DELETE /subdomains/1
  # DELETE /subdomains/1.xml
  def destroy
    @subdomain = Subdomain.find(params[:id])
    @subdomain.destroy

    respond_to do |format|
      format.html { redirect_to :controller => "dashboard" }
    end
  end
end

