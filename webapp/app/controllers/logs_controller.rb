class LogsController < ApplicationController
  before_filter :authenticate_root

  def index
    @loglist = findlogs "/var/log/"

    @logfile = "log/#{RAILS_ENV}.log"
    @logfile = "/var/log/#{params[:file]}" if params[:file]

    begin
      @logtext = File.read(@logfile)
    rescue Exception
      @logtext = "Failed to open file: #{@logfile}"
    end
  end

private

  def findlogs dir
    list = []
    (Dir.entries(dir) - [".", ".."]).each do |e|
      begin
        unless File.directory?(e)
          list << e
        else
          list.concat findlogs(e)
        end
      rescue Exception
      end
    end
    list
  end

end

