### Ohm - Open Hosting Manager <http://joelcogen.com/projects/ohm/> ###
#
# Logs controller
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

class LogsController < ApplicationController
  before_filter :authenticate_root

  def index
    @loglist = LogFile.all

    if params[:logfile]
      @logfile = LogFile.find(params[:logfile][:id])
    else
      @logfile = LogFile.first
    end


    begin
      @logtext = File.read(@logfile.path)
    rescue Exception
      begin
        @logtext = "Failed to open file: #{@logfile.path}"
      rescue NoMethodError
        @logtext = "No logs available"
      end
    end
  end
end

