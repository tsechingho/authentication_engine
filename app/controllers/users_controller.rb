class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update]
  before_filter :find_user, :only => [:show, :edit, :update]

  # GET /users/1
  # GET /account
  def show
  end

  # GET /accept/:invitation_token
  # GET /users/new
  # GET /signup
  def new
    if params[:invitation_token]
      find_invitation
      @user = User.new(
        :name => @invitation.recipient_name,
        :email => @invitation.recipient_email,
        :invitation_id => @invitation.id
      )
    else
      @user = User.new
    end
  end

  # GET /users/1/edit
  # GET /account/edit
  def edit
  end

  # POST /users
  # POST /account
  def create
    @user = User.new

    if @user.signup!(params[:user])
      if @user.invitation
        @user.deliver_activation_confirmation!
        flash[:success] = t('activations.flashs.success.create')
        redirect_to account_url
      else
        @user.deliver_activation_instructions!
        flash[:success] = t('users.flashs.success.create')
        redirect_to root_url
      end
    else
      find_invitation
      render :action => :new
    end
  end

  # PUT /users/1
  # PUT /account
  def update
    if @user.update_attributes(params[:user])
      flash[:success] = t('users.flashs.success.update')
      redirect_to account_url
    else
      render :action => :edit
    end
  end

  protected

  def find_user
    @user = @current_user
  end

  def find_invitation
    @invitation = Invitation.find_by_token(params[:invitation_token])
  end

  private
end
