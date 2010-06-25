# Ohm - Open Hosting Manager <http://ohmanager.sourceforge.net>
# E-mail module - Users controller
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

class ServiceEmailUsersController < ServiceEmailController
  before_filter :authenticate_email_user

  def controller_name
    "e-mail"
  end

  # GET /service_email_users/1
  # GET /service_email_users/1.xml
  def show
    if params[:user_id]
      @service_email_user = ServiceEmailUser.find(:first, :conditions => { :user_id => params[:user_id] })
    elsif params[:id]
      @service_email_user = ServiceEmailUser.find(params[:id])
    end
  end

  # GET /service_email_users/new
  # GET /service_email_users/new.xml
  def new
    @service_email_user = ServiceEmailUser.new(:user_id => params[:user_id])
    @user = User.find(params[:user_id])
  end

  # GET /service_email_users/1/edit
  def edit
    @service_email_user = ServiceEmailUser.find(params[:id])
  end

  # POST /service_email_users
  # POST /service_email_users.xml
  def create
    @service_email_user = ServiceEmailUser.new(params[:service_email_user])

    if @service_email_user.save
      flash[:notice] = 'E-mail service successfully added.'
      redirect_to @service_email_user.user
    else
      render :action => "new"
    end
  end

  # PUT /service_email_users/1
  # PUT /service_email_users/1.xml
  def update
    @service_email_user = ServiceEmailUser.find(params[:id])

    respond_to do |format|
      if @service_email_user.update_attributes(params[:service_email_user])
        flash[:notice] = 'ServiceEmailUser was successfully updated.'
        format.html { redirect_to(@service_email_user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @service_email_user.errors, :status => :unprocessable_entity }
      end
    end
  end
end

