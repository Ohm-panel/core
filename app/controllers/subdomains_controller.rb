class SubdomainsController < ApplicationController
  before_filter :authenticate

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
        flash[:error] = 'Error applying modifications.'
        format.html { redirect_to :controller => "dashboard" }
      end
    end
  end

  # DELETE /subdomains/1
  # DELETE /subdomains/1.xml
  def destroy
    if Subdomain.find(:all).count > 1
      @subdomain = Subdomain.find(params[:id])
      @subdomain.destroy

      # If deleted mainsub, we need to set another one
      if @subdomain.mainsub
        newmain = Subdomain.find(:first)
        newmain.mainsub = true
        newmain.save
      end

      respond_to do |format|
        flash[:notice] = 'Subdomain was successfully deleted.'
        format.html { redirect_to :controller => "dashboard" }
      end
    else
      respond_to do |format|
        flash[:error] = 'You must have at least one subdomain.'
        format.html { redirect_to :controller => "dashboard" }
      end
    end
  end
end

