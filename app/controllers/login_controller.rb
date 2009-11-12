class LoginController < ApplicationController
  before_filter :authenticate, :except => [:index, :login]

  def index
    if loggedin?
      redirect_to :controller => "Users", :action => "index"
    end
    @user = User.new
  end

  def login
    loggedin = false

    # Check credentials
    @user = User.find_by_username(params[:user][:username])
    if @user and @user.password == User.digest_password(params[:user][:password])
      # Create session
      @user.session_ts = Time.new
      @user.session = Digest::MD5.hexdigest(Time.new.to_f.to_s)
      @user.save
      session[:session] = @user.session

      flash[:notice] = 'Login successful'
      redirect_to :controller => "Users", :action => "index"
    else
      flash[:error] = 'Login incorrect'
      redirect_to :action => "index"
    end
  end

  def logout
    if session[:session]
      @user = User.find_by_session(session[:session])
      if @user
        @user.session = nil
        @user.save
        flash[:notice] = 'Logout successful'
      end
    end

    redirect_to :action => "index"
  end

  def changepassword
    @user = @logged_user
  end

  def savenewpassword
    @user = User.find(params[:user][:id])

    respond_to do |format|
      if @user and @user.update_attributes(params[:user])
        flash[:notice] = 'Password successfully changed'
        format.html { redirect_to(@user) }
        format.xml  { head :ok }
      else
        flash[:notice] = 'Error changing password'
        format.html { render :action => "changepassword" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end
end

