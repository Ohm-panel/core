# Configuration controller
class ConfigurationsController < ApplicationController
  before_filter :authenticate_root

  def index
    @configuration = Configuration.first
  end

  def new
    @configuration = Configuration.first
  end

  def edit
    @configuration = Configuration.first
  end

  # POST /configurations
  # POST /configurations.xml
  def create
    @configuration = Configuration.new(params[:configuration])

    if @configuration.save
      flash[:notice] = 'Installation complete'
      redirect_to :controller => 'dashboard', :action => 'index'
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

