class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update]

  def new
    @user = User.new(:invitation_token => params[:invitation_token])
    if @user.invitation
      @user.name = @user.invitation.recipient_name 
      @user.email = @user.invitation.recipient_email 
    end
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      if User.count == 1
        @user.admin = true
        @user.save
        flash[:notice] = "Account registered. You have admin priviliges."
        redirect_to admin_account_url
      else
        flash[:notice] = "Account registered!"
        redirect_back_or_default account_url
      end
    else
      render :action => :new
    end
  end

  def show
    @user = @current_user
  end

  def edit
    @user = @current_user
  end
  
  def update
    @user = @current_user # makes our views "cleaner" and more consistent
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to account_url
    else
      render :action => :edit
    end
  end


end
