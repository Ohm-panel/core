class DashboardController < ApplicationController
  before_filter :authenticate

  def index
    @subdomains_count = 0
    @logged_user.domains.each do |dom|
      @subdomains_count += dom.subdomains.count
    end

    respond_to do |format|
      format.html # index.html.erb
    end
  end

end

