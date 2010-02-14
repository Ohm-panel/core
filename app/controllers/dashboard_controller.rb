class DashboardController < ApplicationController
  before_filter :authenticate

  def index
    respond_to do |format|
      format.html # index.html.erb
    end
  end

end

