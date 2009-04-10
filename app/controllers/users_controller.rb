class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update]

  # GET /users/1
  # GET /account
  def show
    @user = @current_user
  end

  # GET /accept/:invitation_token
  # GET /users/new
  # GET /signup
  def new
    if params[:invitation_token]
      invitation = Invitation.find_by_token(params[:invitation_token])
      @user = User.new(
        :name => invitation.recipient_name,
        :email => invitation.recipient_email,
        :invitation_id => invitation.id
      )
    else
      @user = User.new
    end
  end

  # GET /users/1/edit
  # GET /account/edit
  def edit
    @user = @current_user
  end

  # POST /users
  # POST /account
  def create
    @user = User.new

    if @user.signup!(params[:user])
      @user.deliver_activation_instructions!
      flash[:success] = t('users.flashs.success.create')
      redirect_to root_url
    else
      render :action => :new
    end
  end

  # PUT /users/1
  # PUT /account
  def update
    @user = @current_user
    if @user.update_attributes(params[:user])
      flash[:success] = t('users.flashs.success.update')
      redirect_to account_url
    else
      render :action => :edit
    end
  end
end
