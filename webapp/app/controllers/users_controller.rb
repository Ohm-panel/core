# Ohm - Open Hosting Manager <http://ohmanager.sourceforge.net>
# Users controller
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

class UsersController < ApplicationController
  before_filter :authenticate

  # GET /users
  # GET /users.xml
  def index
    @users = @logged_user.users
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])

    if @user.parent != @logged_user
      flash[:error] = "Invalid user"
      redirect_to :controller => 'users', :action => 'index'
    end

    @available_services = (@logged_user.root? ? Service.all : @logged_user.services) - @user.services
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new
  end

  def profile
    @user = @logged_user
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])

    if @user.parent != @logged_user
      flash[:error] = "Invalid user"
      redirect_to :controller => 'users', :action => 'index'
    end
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])
    @user.parent = @logged_user
    @user.used_space = 0

    if @user.save
      flash[:notice] = 'User was successfully created.'
      redirect_to(@user)
    else
      render :action => "new"
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])

    if @user.parent != @logged_user
      flash[:error] = "Invalid user"
      redirect_to :controller => 'users', :action => 'index'
    elsif @user.update_attributes(params[:user])
      flash[:notice] = 'User was successfully updated.'
      redirect_to @user
    else
      render :action => "edit"
    end
  end

  def profileupdate
    @user = @logged_user
    @newatts = params[:user]
    if @newatts[:password] == ''
      @newatts[:password_confirmation] = nil
      @newatts[:password] = @user.password
    end

    if @user.update_attributes(params[:user])
      flash[:notice] = 'Profile successfully updated.'
      redirect_to :controller => 'dashboard'
    else
      render :action => "profile"
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])

    if @user.parent == @logged_user
      @user.destroy
      # We create a dummy user with parent -1, so Ohmd knows who to remove
      @deluser = User.new(:id => @user.id,
                          :username => @user.username,
                          :parent_id => -1)
      @deluser.save false
    else
      flash[:error] = "Invalid user"
    end

    redirect_to(users_url)
  end

  def addservice
    @user = User.find(params[:user_id])
    @service = Service.find(params[:service_id][0])

    if @logged_user.root? or (@user.parent == @logged_user and @logged_user.services.include? @service)
      @user.services << @service

      if @user.save
        flash[:notice] = 'Service successfully added'
        redirect_to :controller => @service.controller, :action => 'addtouser', :user_id => @user.id
      else
        flash[:error] = 'Error occured'
        redirect_to @user
      end
    else
      flash[:error] = 'Invalid user'
      redirect_to users_path
    end
  end

  def removeservice
    @user = User.find(params[:user_id])
    @service = Service.find(params[:service_id])

    if @user.parent == @logged_user and @logged_user.services.include? @service
      @user.services.delete(@service)

      if @user.save
        flash[:notice] = 'Service successfully removed'
        redirect_to :controller => @service.controller, :action => 'removefromuser', :user_id => @user.id
      else
        flash[:error] = 'Error occured'
        redirect_to @user
      end
    else
      flash[:error] = 'Invalid user'
      redirect_to users_path
    end
  end

  def login_as_me
    @user = User.find(params[:id])
    if @user.parent == @logged_user or @logged_user.root?
      login_as @user
      flash[:notice] = 'Logged in as ' + @user.full_name
      redirect_to :controller => 'dashboard'
    else
      flash[:error] = @user.full_name + ' is not your sub-user!'
      redirect_to users_path
    end
  end
end

