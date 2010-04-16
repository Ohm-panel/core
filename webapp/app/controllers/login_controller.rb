class LoginController < ApplicationController
  before_filter :authenticate, :except => [:index, :login, :setup, :dosetup]

  def index
    if User.all.count == 0
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
    redirect_to :action => 'index' if User.all.count > 0

    @user = User.new
  end

  def dosetup
    redirect_to :action => 'index' if User.all.count > 0

    @user = User.new(params[:user])
    @user.id = 1
    @user.parent_id = nil

    if @user.save
      login_as @user
      redirect_to :controller => "configurations", :action => "new"
    else
      render :action => "setup"
    end
  end
end

