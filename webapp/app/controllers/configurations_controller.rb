class ConfigurationsController < ApplicationController
  before_filter :authenticate_root
    
  def index
    @configuration = Configuration.all.first
  end

  def new
    @configuration = Configuration.new(:enable_www => true,
                                       :enable_dns => true,
                                       :enable_ssh => true)
  end

  def edit
    @configuration = Configuration.all.first
  end

  # POST /configurations
  # POST /configurations.xml
  def create
    @configuration = Configuration.new(params[:configuration])

    if @configuration.save
      flash[:notice] = 'Configuration was successfully created.'
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  # PUT /configurations/1
  # PUT /configurations/1.xml
  def update
    @configuration = Configuration.find(params[:id])

    if @configuration.update_attributes(params[:configuration])
      flash[:notice] = 'Configuration was successfully updated.'
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end
end
