class PureftpdAccountsController < PureftpdController
  before_filter :authenticate_pureftpd_user

  def controller_name
    "FTP"
  end

  def index
    @accounts = @logged_pureftpd_user.pureftpd_accounts
  end

  def new
    @account = PureftpdAccount.new
  end

  def edit
    @account = PureftpdAccount.find(params[:id])

    unless @account.pureftpd_user == @logged_pureftpd_user
      flash[:error] = 'Invalid account'
      redirect_to :action => 'index'
    end
  end

  def create
    @account = PureftpdAccount.new(params[:pureftpd_account])
    @account.pureftpd_user = @logged_pureftpd_user
    
    if @account.save
      flash[:notice] = 'Account successfully created.'
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def update
    @account = PureftpdAccount.find(params[:id])
    @newatts = params[:pureftpd_account]
    if @newatts[:password] == ''
      @newatts[:password_confirmation] = nil
      @newatts[:password] = @account.password
    end

    if not @account.pureftpd_user == @logged_pureftpd_user
      flash[:error] = 'Invalid account'
      redirect_to :action => 'index'
    elsif @account.update_attributes(params[:pureftpd_account])
      flash[:notice] = @account.username + ' was successfully updated.'
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end

  def destroy
    @account = PureftpdAccount.find(params[:id])

    if @account.pureftpd_user == @logged_pureftpd_user
      @account.destroy

      flash[:notice] = @account.username + ' was successfully deleted.'
      redirect_to :action => 'index'
    else
      flash[:error] = 'Invalid account'
      redirect_to :action => 'index'
    end
  end
end

