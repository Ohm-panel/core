class OhmdController < ApplicationController
  before_filter "authenticate_ohmd(params[:passphrase])", :except => [:badlogin]
  skip_before_filter :verify_authenticity_token
  layout nil

  def index
    @urls = ["ohmd/users", "ohmd/apache"]
  end

  def apache
  end

  def users
    @users = User.find(:all).select { |u| !u.root? }
  end

  def badlogin
  end
end

