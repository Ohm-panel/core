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
    @users_to_add = User.find(:all).select { |u| !u.root? && u.ohmd_status==User::OHMD_TO_ADD }
    @users_to_mod = User.find(:all).select { |u| !u.root? && u.ohmd_status==User::OHMD_TO_MOD }
    @users_to_del = User.find(:all).select { |u| !u.root? && u.ohmd_status==User::OHMD_TO_DEL }

    if(params[:done])
      if(params[:success])
        done_users = params[:report_values].collect { |junk, id| User.find(id) }
        done_users.each do |u|
          if @users_to_add.include?(u) || @users_to_mod.include?(u)
            u.ohmd_status = User::OHMD_OK
            u.ohmd_password = nil
            u.save false
          elsif @users_to_del.include?(u)
            u.destroy
          end
        end

        @users_to_add = nil
        @users_to_mod = nil
        @users_to_del = nil
      end
    end
  end

  def badlogin
  end
end

