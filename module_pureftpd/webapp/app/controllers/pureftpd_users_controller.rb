class PureftpdUsersController < PureftpdController
  before_filter :authenticate_pureftpd_user

  def controller_name
    "FTP"
  end

  def show
    if params[:user_id]
      @pureftpd_user = PureftpdUser.find(:first, :conditions => { :user_id => params[:user_id] })
    elsif params[:id]
      @pureftpd_user = PureftpdUser.find(params[:id])
    end
  end

  def new
    @pureftpd_user = PureftpdUser.new(:user_id => params[:user_id])
    @user = User.find(params[:user_id])
  end

  def edit
    @pureftpd_user = PureftpdUser.find(params[:id])
  end

  def create
    @pureftpd_user = PureftpdUser.new(params[:pureftpd_user])

    if @pureftpd_user.save
      flash[:notice] = 'FTP service successfully added.'
      redirect_to @pureftpd_user.user
    else
      render :action => "new"
    end
  end

  def update
    @pureftpd_user = PureftpdUser.find(params[:id])

    if @pureftpd_user.update_attributes(params[:pureftpd_user])
      flash[:notice] = 'FTP user was successfully updated.'
      redirect_to(@pureftpd_user)
    else
      render :action => "edit"
    end
  end
end

