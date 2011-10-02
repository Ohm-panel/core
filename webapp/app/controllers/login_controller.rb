### Ohm - Open Hosting Manager <http://joelcogen.com/projects/ohm/> ###
#
# Login controller
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

class LoginController < ApplicationController
  before_filter :authenticate, :except => [:index, :login, :setup, :dosetup]

  def index
    if User.count == 0
      redirect_to :action => 'setup'
    elsif findsession
      redirect_to :controller => 'dashboard', :action => 'index'
    end
    @user = User.new
  end

  def login
    # Check credentials
    @user = User.find_by_username(params[:user][:username])
    if @user and @user.password == User.digest_password(params[:user][:password])
      login_as @user
      flash[:notice] = 'Login successful'
      redirect_to :controller => "dashboard", :action => "index"
    else
      flash[:error] = 'Login incorrect'
      redirect_to :action => "index"
    end
  end

  def logout
    lu = findsession
    if lu
      lu.destroy
      reset_session
      flash[:notice] = 'Logout successful'
    end
    redirect_to :action => "index"
  end

  def setup
    redirect_to :action => 'index' if User.count > 0

    @user = User.new
  end

  def dosetup
    redirect_to :action => 'index' if User.count > 0

    @user = User.new(params[:user])
    @user.id = 1
    @user.parent_id = nil

    if @user.save
      login_as @user
      redirect_to new_configuration_path
    else
      render :action => "setup"
    end
  end
end

