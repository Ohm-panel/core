# Ohm - Open Hosting Manager <http://ohmanager.sourceforge.net>
# Subdomains controller
#
# Copyright (C) 2009-2010 UMONS <http://www.umons.ac.be>
#
# This file is part of Ohm.
#
# Ohm is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ohm is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ohm. If not, see <http://www.gnu.org/licenses/>.

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
      flash[:notice] = "Subdomain was successfully created.#{@@changes}"
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
      flash[:notice] = "Subdomain was successfully updated.#{@@changes}"
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

        flash[:notice] = "Subdomain was successfully deleted.#{@@changes}"
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

