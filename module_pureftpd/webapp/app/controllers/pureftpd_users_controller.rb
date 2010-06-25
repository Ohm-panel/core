# Ohm - Open Hosting Manager <http://ohmanager.sourceforge.net>
# PureFTPd module - Users controller
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

class PureftpdUsersController < PureftpdController
  before_filter :authenticate_pureftpd_user

  def controller_name
    "FTP"
  end

  def show
    if params[:user_id]
      @pureftpd_user = PureftpdUser.find(:first, :conditions => { :user_id => params[:user_id] })
    elsif params[:id]
      @pureftpd_user = PureftpdUser.find(params[:id])
    end
  end

  def new
    @pureftpd_user = PureftpdUser.new(:user_id => params[:user_id])
    @user = User.find(params[:user_id])
  end

  def edit
    @pureftpd_user = PureftpdUser.find(params[:id])
  end

  def create
    @pureftpd_user = PureftpdUser.new(params[:pureftpd_user])

    if @pureftpd_user.save
      flash[:notice] = 'FTP service successfully added.'
      redirect_to @pureftpd_user.user
    else
      render :action => "new"
    end
  end

  def update
    @pureftpd_user = PureftpdUser.find(params[:id])

    if @pureftpd_user.update_attributes(params[:pureftpd_user])
      flash[:notice] = 'FTP user was successfully updated.'
      redirect_to(@pureftpd_user)
    else
      render :action => "edit"
    end
  end
end

