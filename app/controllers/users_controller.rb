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
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])
    @user.parent = @logged_user
    @user.used_space = 0

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

  def profileupdate
    @user = @logged_user
    @newatts = params[:user]
    if @newatts[:password] == ''
      @newatts[:password_confirmation] = nil
      @newatts[:password] = @user.password
    end

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'Profile successfully updated.'
        format.html { redirect_to :controller => 'dashboard' }
      else
        format.html { render :action => "profile" }
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

  def login_as_me
    @user = User.find(params[:id])
    if @user.parent == @logged_user or @logged_user.root?
      login_as @user
      flash[:notice] = 'Logged in as ' + @user.full_name
      redirect_to :controller => 'dashboard', :action => 'index'
    else
      flash[:error] = @user.full_name + ' is not your sub-user!'
      redirect_to :controller => 'users', :action => 'index'
    end
  end
end

