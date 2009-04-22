class PasswordResetsController < ApplicationController
  before_filter :require_no_user
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]

  # GET /password_resets/new
  def new
    render
  end

  # GET /password_resets/1/edit
  def edit
    render
  end

  # POST /password_resets
  def create
    @user = User.find_by_email(params[:email])
    if @user
      @user.deliver_password_reset_instructions!
      flash[:success] = t('password_resets.flashs.success.create')
      redirect_to root_url
    else
      flash[:error] = t('password_resets.flashs.errors.create')
      render :action => :new
    end
  end

  # PUT /password_resets/1
  def update
    if @user.reset_password!(params[:user])
      flash[:success] = t('password_resets.flashs.success.update')
      redirect_to account_url
    else
      render :action => :edit
    end
  end

  private

  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = t('password_resets.flashs.errors.update')
    redirect_to root_url
  end
end
