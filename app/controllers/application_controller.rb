# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  layout "ohm"

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password

  @@timeout = 600

  def authenticate
    lu = findsession
    if lu
      @logged_user = lu.user
      true
    else
      flash[:error] = "Your session has expired"
      redirect_to :controller => "Login", :action => "index"
      false
    end
  end

  def login_as user
    lu = findsession
    if lu
      # Session exists, update
      lu.update_attribute(:user, user)
    else
      # Create
      lu = LoggedUser.new
      lu.user = user
      lu.session_ts = Time.new
      lu.session = Digest::MD5.hexdigest(Time.new.to_f.to_s + user.full_name + user.used_space.to_s)
      lu.ip = request.remote_ip
      lu.save
      session[:session] = lu.session
    end
  end

  def findsession
    return nil unless session[:session] # No existing session

    lu = LoggedUser.find(:first, :conditions => { :session => session[:session], :ip => request.remote_ip })
    if lu
      # Session found, check time
      if Time.new - lu.session_ts <= @@timeout
        lu.update_attribute(:session_ts, Time.new)
        lu
      else
        lu.destroy
        nil
      end
    else
      # Bogus session
      nil
    end
  end
end

