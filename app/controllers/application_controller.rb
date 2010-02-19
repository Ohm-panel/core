# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  layout "ohm"

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password

  def authenticate
    unless loggedin?
      redirect_to :controller => "Login", :action => "index"
    end
    return loggedin?
  end

  def loggedin?
    if session[:session]
      @user = User.find_by_session(session[:session])
      if !@user
        # Bogus session
        false
      elsif Time.new - @user.session_ts > 600
        # Session expired
        @user.session = nil
        @user.save false
        false
      else
        @user.session_ts = Time.new
        @user.save false
        @logged_user = @user
        true
      end
    else
      false
    end
  end

  def login_as user
    # Create session (keep current one if exists, so we can connect from several locations at the same time)
    user.session_ts = Time.new
    user.session = Digest::MD5.hexdigest(Time.new.to_f.to_s) unless user.session
    user.save
    session[:session] = user.session
  end
end

