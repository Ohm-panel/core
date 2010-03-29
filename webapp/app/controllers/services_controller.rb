require 'ftools'
require 'yaml'

class ServicesController < ApplicationController
  before_filter :authenticate_root

  def controller_name
    "modules"
  end

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
    # Save file
    file = DataFile.save(params[:upload])
    unless file
      flash[:error] = 'Upload failed, please try again'
      redirect_to :action => "new"
      return
    end

    # Untar
    unless file.match(/.tar.gz\Z/) || file.match(/.tar.bz2\Z/)
      File.delete file
      flash[:error] = 'Only tar.gz and tar.bz2 archives are supported'
      redirect_to :action => "new"
      return
    end
    extractpath = "public/data/module_install_#{Time.new.to_i}"
    File.makedirs extractpath
    tarok = system "tar -xpf #{file} -C #{extractpath}"
    File.delete file
    unless tarok
      flash[:error] = 'An error occured trying to extract the file. Please verify its integrity and try again'
      redirect_to :action => "new"
      return
    end

    # Copy on panel
    # TODO: check content!
    cpok = system "cp -rp #{extractpath}/webapp/* ./"
    unless cpok
      system "rm -rf #{extractpath}"
      flash[:error] = 'An error occured during installation. Please verify the uploaded module is for this version of Ohm'
      redirect_to :action => "new"
      return
    end

    # Migrate DB
    dbversion = `rake db:version`.split(": ")[1]
    migrateok = system "rake db:migrate RAILS_ENV=#{RAILS_ENV}"
    unless migrateok
      system "rake db:migrate RAILS_ENV=#{RAILS_ENV} VERSION=#{dbversion}"
      flash[:error] = 'An error occured during installation. Please verify the uploaded module is for this version of Ohm'
      redirect_to :action => "new"
      return
    end

    # Create service
    begin
      modcfg = YAML.load_file("#{extractpath}/module.yml")
      @service = Service.new(modcfg)
      @service.daemon_installed = false
      @service.install_files = extractpath
      @service.save or raise Exception
      @logged_user.services << @service
      @logged_user.save or raise Exception
    rescue Exception
      system "rake db:migrate RAILS_ENV=#{RAILS_ENV} VERSION=#{dbversion}"
      flash[:error] = 'An error occured during installation. Please verify the uploaded module is for this version of Ohm'
      redirect_to :action => "new"
      return
    end

    flash[:notice] = 'Module successfully uploaded, installation will be finished in a few minutes.'
    redirect_to :action => "index"
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

