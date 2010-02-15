class ServiceEmailMailboxesController < ApplicationController
  before_filter :authenticate

  # GET /service_email_mailboxes
  # GET /service_email_mailboxes.xml
  def index
    @service_email_mailboxes = ServiceEmailMailbox.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @service_email_mailboxes }
    end
  end

  # GET /service_email_mailboxes/1
  # GET /service_email_mailboxes/1.xml
  def show
    @service_email_mailbox = ServiceEmailMailbox.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @service_email_mailbox }
    end
  end

  # GET /service_email_mailboxes/new
  # GET /service_email_mailboxes/new.xml
  def new
    @service_email_mailbox = ServiceEmailMailbox.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @service_email_mailbox }
    end
  end

  # GET /service_email_mailboxes/1/edit
  def edit
    @service_email_mailbox = ServiceEmailMailbox.find(params[:id])
  end

  # POST /service_email_mailboxes
  # POST /service_email_mailboxes.xml
  def create
    @service_email_mailbox = ServiceEmailMailbox.new(params[:service_email_mailbox])

    respond_to do |format|
      if @service_email_mailbox.save
        flash[:notice] = 'ServiceEmailMailbox was successfully created.'
        format.html { redirect_to(@service_email_mailbox) }
        format.xml  { render :xml => @service_email_mailbox, :status => :created, :location => @service_email_mailbox }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @service_email_mailbox.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /service_email_mailboxes/1
  # PUT /service_email_mailboxes/1.xml
  def update
    @service_email_mailbox = ServiceEmailMailbox.find(params[:id])

    respond_to do |format|
      if @service_email_mailbox.update_attributes(params[:service_email_mailbox])
        flash[:notice] = 'ServiceEmailMailbox was successfully updated.'
        format.html { redirect_to(@service_email_mailbox) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @service_email_mailbox.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /service_email_mailboxes/1
  # DELETE /service_email_mailboxes/1.xml
  def destroy
    @service_email_mailbox = ServiceEmailMailbox.find(params[:id])
    @service_email_mailbox.destroy

    respond_to do |format|
      format.html { redirect_to(service_email_mailboxes_url) }
      format.xml  { head :ok }
    end
  end
end

