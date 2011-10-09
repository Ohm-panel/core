### Ohm - Open Hosting Manager <http://joelcogen.com/projects/ohm/> ###
#
# Configuration controller
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

