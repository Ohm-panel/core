# Dashboard controller
class DashboardController < ApplicationController
  before_filter :authenticate

  def index
    @user = @logged_user

    respond_to do |format|
      format.html # index.html.erb
    end
  end

end

