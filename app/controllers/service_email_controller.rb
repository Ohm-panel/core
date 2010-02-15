class ServiceEmailController < ApplicationController
  before_filter :authenticate

  def index
    @mailboxes = ServiceEmailMailbox.find(:all, :conditions=>{:domain_id=>@logged_user.domains})

    respond_to do |format|
      format.html # index.html.erb
    end
  end

end

