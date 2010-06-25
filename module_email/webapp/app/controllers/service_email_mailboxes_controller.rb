# Ohm - Open Hosting Manager <http://ohmanager.sourceforge.net>
# E-mail module - Mailboxes controller
#
# Copyright (C) 2009-2010 UMONS <http://www.umons.ac.be>
#
# This file is part of Ohm.
#
# Ohm is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ohm is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ohm. If not, see <http://www.gnu.org/licenses/>.

class ServiceEmailMailboxesController < ServiceEmailController
  before_filter :authenticate_email_user

  def controller_name
    "e-mail"
  end

  # GET /service_email_mailboxes
  # GET /service_email_mailboxes.xml
  def index
    @mailboxes = ServiceEmailMailbox.all
  end

  # GET /service_email_mailboxes/new
  # GET /service_email_mailboxes/new.xml
  def new
    @mailbox = ServiceEmailMailbox.new
  end

  # GET /service_email_mailboxes/1/edit
  def edit
    @mailbox = ServiceEmailMailbox.find(params[:id])

    unless @logged_user.domains.include? @mailbox.domain
      flash[:error] = 'Invalid mailbox'
      redirect_to :action => 'index'
    end
  end

  # POST /service_email_mailboxes
  # POST /service_email_mailboxes.xml
  def create
    @mailbox = ServiceEmailMailbox.new(params[:service_email_mailbox])
    legal_domain = @logged_user.domains.include? @mailbox.domain

    if legal_domain and @mailbox.save
      flash[:notice] = 'Mailbox successfully created.'
      redirect_to :action => 'index'
    else
      @mailbox.errors.add(:domain_id, 'is not managed by you') unless legal_domain
      render :action => 'new'
    end

  end

  # PUT /service_email_mailboxes/1
  # PUT /service_email_mailboxes/1.xml
  def update
    @mailbox = ServiceEmailMailbox.find(params[:id])
    @newatts = params[:service_email_mailbox]
    if @newatts[:password] == ''
      @newatts[:password_confirmation] = nil
      @newatts[:password] = @mailbox.password
    end

    if not @logged_user.domains.include? @mailbox.domain
      flash[:error] = 'Invalid mailbox'
      redirect_to :action => 'index'
    elsif @mailbox.update_attributes(params[:service_email_mailbox])
      flash[:notice] = @mailbox.full_address + ' was successfully updated.'
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end

  # DELETE /service_email_mailboxes/1
  # DELETE /service_email_mailboxes/1.xml
  def destroy
    @mailbox = ServiceEmailMailbox.find(params[:id])

    if @logged_user.domains.include? @mailbox.domain
      @mailbox.destroy

      flash[:notice] = @mailbox.full_address + ' was successfully deleted.'
      redirect_to :action => 'index'
    else
      flash[:error] = 'Invalid mailbox'
      redirect_to :action => 'index'
    end
  end
end

