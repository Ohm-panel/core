### Ohm - Open Hosting Manager <http://joelcogen.com/projects/ohm/> ###
#
# Domains controller
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
          flash[:notice] = "Domain was successfully added.#{@@changes}"
          format.html { redirect_to @domain }
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
        redirect_to @domain
      end
    else
      flash[:error] = "Invalid domain or service"
      redirect_to :controller => 'domains'
    end
  end
end

