# Ohm - Open Hosting Manager <http://ohmanager.sourceforge.net>
# PureFTPd module - Accounts controller
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

class PureftpdAccountsController < PureftpdController
  before_filter :authenticate_pureftpd_user

  def controller_name
    "FTP"
  end

  def index
    @accounts = @logged_pureftpd_user.pureftpd_accounts
  end

  def new
    @account = PureftpdAccount.new
  end

  def edit
    @account = PureftpdAccount.find(params[:id])

    unless @account.pureftpd_user == @logged_pureftpd_user
      flash[:error] = 'Invalid account'
      redirect_to :action => 'index'
    end
  end

  def create
    @account = PureftpdAccount.new(params[:pureftpd_account])
    @account.pureftpd_user = @logged_pureftpd_user

    if @account.save
      flash[:notice] = 'Account successfully created.'
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def update
    @account = PureftpdAccount.find(params[:id])
    @newatts = params[:pureftpd_account]
    if @newatts[:password] == ''
      @newatts[:password_confirmation] = nil
      @newatts[:password] = @account.password
    end

    if not @account.pureftpd_user == @logged_pureftpd_user
      flash[:error] = 'Invalid account'
      redirect_to :action => 'index'
    elsif @account.update_attributes(params[:pureftpd_account])
      flash[:notice] = @account.username + ' was successfully updated.'
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end

  def destroy
    @account = PureftpdAccount.find(params[:id])

    if @account.pureftpd_user == @logged_pureftpd_user
      @account.destroy

      flash[:notice] = @account.username + ' was successfully deleted.'
      redirect_to :action => 'index'
    else
      flash[:error] = 'Invalid account'
      redirect_to :action => 'index'
    end
  end
end

