### Ohm - Open Hosting Manager <http://joelcogen.com/projects/ohm/> ###
#
# Application controller
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

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  layout "ohm"

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password

  @@timeout = 600
  @@changes = "<br/>Changes may take up to 5 minutes to take effect"

private

  def authenticate
    lu = findsession
    if lu
      @logged_user = lu.user
      true
    else
      redirect_to :controller => "Login", :action => "index"
      false
    end
  end

  def authenticate_root
    if authenticate
      if @logged_user.root?
        true
      else
        flash[:error] = 'You are not authorized to access this page'
        redirect_to :controller => 'dashboard'
        false
      end
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
      lu.session = Digest::MD5.hexdigest(Time.new.to_f.to_s + user.username + user.used_space.to_s)
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
        flash[:error] = "Your session has expired"
        nil
      end
    else
      # Bogus session
      nil
    end
  end
end

