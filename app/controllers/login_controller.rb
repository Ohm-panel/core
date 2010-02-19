class LoginController < ApplicationController
#  before_filter :authenticate, :except => [:index, :login]

  def index
    if loggedin?
      redirect_to :controller => "dashboard", :action => "index"
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
    if session[:session]
      session[:session] = nil
      flash[:notice] = 'Logout successful'
    end
    redirect_to :action => "index"
  end
end

