class UsersController < ApplicationController
  before_filter :authenticate

  # GET /users
  # GET /users.xml
  def index
    @users = @logged_user.users

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])
    @available_services = @logged_user.services - @user.services

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        flash[:notice] = 'User was successfully created.'
        format.html { redirect_to(@user) }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end

  def addservice
    @user = User.find(params[:user_id])
    @user.services << Service.find(params[:service_id])

    respond_to do |format|
      if @user.save
        flash[:notice] = 'Service successfully added'
        format.html { redirect_to(@user) }
        format.xml  { head :ok }
      else
        flash[:notice] = 'Error occured'
        format.html { redirect_to(@user) }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def removeservice
    @user = User.find(params[:user_id])
    @user.services.delete(Service.find(params[:service_id]))

    respond_to do |format|
      if @user.save
        flash[:notice] = 'Service successfully removed'
        format.html { redirect_to(@user) }
        format.xml  { head :ok }
      else
        flash[:notice] = 'Error occured'
        format.html { redirect_to(@user) }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end
end

