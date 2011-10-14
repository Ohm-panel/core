# Logs controller
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

