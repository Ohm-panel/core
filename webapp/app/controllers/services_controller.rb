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

  # GET /services/new
  # GET /services/new.xml
  def new
    @service = Service.new
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
      flash[:error] = 'An error occured during file copy. Please verify the uploaded module is for this version of Ohm'
      redirect_to :action => "new"
      return
    end
    system "chmod -R go-rwx ./"

    # Migrate DB
    dbversion = `rake db:version RAILS_ENV=#{RAILS_ENV}`.split(": ")[1].to_i
    # Renumber migrations to avoid conflicts
    newversion = dbversion + 1
    begin
      Dir.entries("#{extractpath}/webapp/db/migrate").each do |m|
        next unless File.file? "#{extractpath}/webapp/db/migrate/#{m}"
        splitname = m.split(/\A\d+/)
        newname = "#{newversion}#{splitname[1]}"
        File.rename("db/migrate/#{m}", "db/migrate/#{newname}")
        newversion += 1
      end
    rescue Exception
      flash[:error] = 'An error occured during migration preparation. Please verify the uploaded module is for this version of Ohm'
      redirect_to :action => "new"
      return
    end
    # Actual migration
    migrateok = system "rake db:migrate RAILS_ENV=#{RAILS_ENV}"
    unless migrateok
      system "rake db:migrate RAILS_ENV=#{RAILS_ENV} VERSION=#{dbversion}"
      flash[:error] = 'An error occured during database migration. Please verify the uploaded module is for this version of Ohm'
      redirect_to :action => "new"
      return
    end

    # Create service
    begin
      modcfg = YAML.load_file("#{extractpath}/module.yml")
      @service = Service.new(modcfg)
      @service.daemon_installed = false
      @service.deleted = false
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

    flash[:notice] = 'Module successfully uploaded.<br />To complete the installation, please log onto the server using SSH and run (as root) \'ohm-install-modules\''
    redirect_to :action => "index"
  end

  # DELETE /services/1
  # DELETE /services/1.xml
  def destroy
    @service = Service.find(params[:id])
    @service.update_attribute(:deleted, true)

    redirect_to services_url
  end
end

