class LoginController < ApplicationController
  before_filter :authenticate, :except => [:index, :login]

  def index
    if loggedin?
      redirect_to :controller => "dashboard", :action => "index"
    end
    @user = User.new
  end

  def login
    loggedin = false

    # Check credentials
    @user = User.find_by_username(params[:user][:username])
    if @user and @user.password == User.digest_password(params[:user][:password])
      # Create session (keep current one if exists, so we can connect from several locations at the same time)
      @user.session_ts = Time.new
      @user.session = Digest::MD5.hexdigest(Time.new.to_f.to_s) unless @user.session
      @user.save
      session[:session] = @user.session

      flash[:notice] = 'Login successful'
      redirect_to :controller => "dashboard", :action => "index"
    else
      flash[:error] = 'Login incorrect'
      redirect_to :action => "index"
    end
  end

  def logout
    if session[:session]
#      @user = User.find_by_session(session[:session])
#      if @user
#        @user.session = nil
#        @user.save
      session[:session] = nil
      flash[:notice] = 'Logout successful'
#      end
    end

    redirect_to :action => "index"
  end
end

