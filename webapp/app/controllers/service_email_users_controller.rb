class ServiceEmailUsersController < ServiceEmailController
  before_filter :authenticate_email_user

  # GET /service_email_users/1
  # GET /service_email_users/1.xml
  def show
    if params[:user_id]
      @service_email_user = ServiceEmailUser.find(:first, :conditions => { :user_id => params[:user_id] })
    elsif params[:id]
      @service_email_user = ServiceEmailUser.find(params[:id])
    end
  end

  # GET /service_email_users/new
  # GET /service_email_users/new.xml
  def new
    @service_email_user = ServiceEmailUser.new(:user_id => params[:user_id])
    @user = User.find(params[:user_id])
  end

  # GET /service_email_users/1/edit
  def edit
    @service_email_user = ServiceEmailUser.find(params[:id])
  end

  # POST /service_email_users
  # POST /service_email_users.xml
  def create
    @service_email_user = ServiceEmailUser.new(params[:service_email_user])

    if @service_email_user.save
      flash[:notice] = 'E-mail service successfully added.'
      redirect_to @service_email_user.user
    else
      render :action => "new"
    end
  end

  # PUT /service_email_users/1
  # PUT /service_email_users/1.xml
  def update
    @service_email_user = ServiceEmailUser.find(params[:id])

    respond_to do |format|
      if @service_email_user.update_attributes(params[:service_email_user])
        flash[:notice] = 'ServiceEmailUser was successfully updated.'
        format.html { redirect_to(@service_email_user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @service_email_user.errors, :status => :unprocessable_entity }
      end
    end
  end
end

