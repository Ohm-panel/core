class SubdomainsController < ApplicationController
  before_filter :authenticate

  # GET /subdomains/new
  # GET /subdomains/new.xml
  def new
    @subdomain = Subdomain.new
    @subdomain.domain = Domain.find(params[:domain])

    if @subdomain.domain.user != @logged_user
      flash[:error] = 'Invalid subdomain'
      redirect_to :controller => 'domains'
    end
  end

  # GET /subdomains/1/edit
  def edit
    @subdomain = Subdomain.find(params[:id])

    if @subdomain.domain.user != @logged_user
      flash[:error] = 'Invalid subdomain'
      redirect_to :controller => 'domains'
    end
  end

  # POST /subdomains
  # POST /subdomains.xml
  def create
    @subdomain = Subdomain.new(params[:subdomain])

    if @subdomain.domain.user != @logged_user
      flash[:error] = 'Invalid domain'
      redirect_to :controller => 'domains'
    elsif @subdomain.save
      flash[:notice] = 'Subdomain was successfully created.'
      redirect_to @subdomain.domain
    else
      flash[:error] = 'Error occured.'
      redirect_to @subdomain.domain
    end
  end

  # PUT /subdomains/1
  # PUT /subdomains/1.xml
  def update
    @subdomain = Subdomain.find(params[:id])

    if @subdomain.domain.user != @logged_user or params[:subdomain][:domain_id] or params[:subdomain][:domain]
      flash[:error] = 'Invalid domain'
      redirect_to :controller => "domains"
    elsif @subdomain.update_attributes(params[:subdomain])
      flash[:notice] = 'Subdomain was successfully updated.'
      redirect_to @subdomain.domain
    else
      flash[:error] = 'Error applying modifications.'
      redirect_to @subdomain.domain
    end
  end

  # DELETE /subdomains/1
  # DELETE /subdomains/1.xml
  def destroy
    @subdomain = Subdomain.find(params[:id])
    if @subdomain.domain.subdomains.count > 1
      if @subdomain.domain.user == @logged_user
        # If deleted mainsub, we need to set another one
        if @subdomain.mainsub
          newmain = @subdomain.domain.subdomains.select {|s| s != @subdomain}.first
          newmain.update_attribute(:mainsub, true)
        end
        @subdomain.destroy

        flash[:notice] = 'Subdomain was successfully deleted.'
        redirect_to @subdomain.domain
      else
        flash[:error] = 'Invalid subdomain'
        redirect_to :controller => "domains"
      end
    else
      flash[:error] = 'Cannot delete last subdomain'
      redirect_to @subdomain.domain
    end
  end
end

