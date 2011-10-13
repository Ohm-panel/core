### Ohm - Open Hosting Manager <http://joelcogen.com/projects/ohm/> ###
#
# Services controller (modules)
#
# Copyright (C) 2009-2010 UMONS <http://www.umons.ac.be>
# Copyright (C) 2010 Joel Cogen <http://joelcogen.com>
#
# This file is part of Ohm.
#
# Ohm is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ohm is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with Ohm. If not, see <http://www.gnu.org/licenses/>.

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

    # Untar config
    unless file.match(/.tar.gz\Z/) || file.match(/.tar.bz2\Z/)
      File.delete file
      flash[:error] = 'Only tar.gz and tar.bz2 archives are supported'
      redirect_to :action => "new"
      return
    end
    begin
      modcfg = YAML.load `tar -xOf #{file} module.yml`
      mod_controller_name = modcfg['controller']
    rescue
      flash[:error] = 'An error occured during installation. Could not read module configuration'
      redirect_to :action => "new"
      return
    end

    # Untar files
    extractpath = "vendor/plugins/#{mod_controller_name}"
    system "mv #{extractpath} #{extractpath}_bak"
    File.makedirs extractpath
    tarok = system "tar -xpf #{file} -C #{extractpath}"
    File.delete file
    unless tarok
      system "rm -rf #{extractpath}"
      system "mv #{extractpath}_bak #{extractpath}"
      flash[:error] = 'An error occured trying to extract the file. Please verify its integrity and try again'
      redirect_to :action => "new"
      return
    end
    system "rm -rf #{extractpath}_bak"

    # Install from Rake task
    install_ok = RAILS_ENV=="development" || system("rake ohmd:#{mod_controller_name}:install RAILS_ENV=#{RAILS_ENV}")
    unless install_ok
      system "rake ohmd:#{mod_controller_name}:remove RAILS_ENV=#{RAILS_ENV}"
      flash[:error] = 'An error occured during plugin installation. Please verify the uploaded module is for this distribution'
      redirect_to :action => "new"
      return
    end

    # Migrate DB
    migrate_ok = system "rake ohmd:#{mod_controller_name}:db_up RAILS_ENV=#{RAILS_ENV}"
    unless migrate_ok
      system "rake ohmd:#{mod_controller_name}:db_down RAILS_ENV=#{RAILS_ENV}"
      flash[:error] = 'An error occured during database migration. Please verify the uploaded module is for this version of Ohm'
      redirect_to :action => "new"
      return
    end

    # Create service
    begin
      service_attributes = {
        :install_files => extractpath
      }.merge(modcfg)
      @service = Service.create! service_attributes
      @logged_user.services << @service
      @logged_user.save!
    rescue => e
      system "rake ohmd:#{mod_controller_name}:db_down RAILS_ENV=#{RAILS_ENV}"
      raise e
    end

    flash[:notice] = 'Module successfully installed'
    redirect_to :action => "index"
  end

  # DELETE /services/1
  # DELETE /services/1.xml
  def destroy
    # Mark service as deleted
    @service = Service.find(params[:id])
    mod_controller_name = @service.controller
    @service.destroy

    # Undo migrations
    migrate_ok = system "rake ohmd:#{mod_controller_name}:db_down RAILS_ENV=#{RAILS_ENV}"
    unless migrate_ok
      flash[:error] = 'An error occured during database rollback'
      redirect_to :action => "index"
      return
    end

    # Install from Rake task
    install_ok = RAILS_ENV=="development" || system("rake ohmd:#{mod_controller_name}:remove RAILS_ENV=#{RAILS_ENV}")
    unless install_ok
      flash[:error] = 'An error occured during plugin removal'
      redirect_to :action => "index"
      return
    end
    
    redirect_to services_url
  end
end

