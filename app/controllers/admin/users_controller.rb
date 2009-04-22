class Admin::UsersController < Admin::AdminController
  before_filter :limited_signup, :only => [:new, :create]
  before_filter :find_user, :only => [:show, :edit, :update]

  def index
    @users = User.all
  end

  def show
  end

  def new
    @user = User.new
  end

  #def edit
  #end

  def create
    @user = User.new

    @user.signup_without_credentials!(params[:user]) do |result|
      if result
        current_user.increment! :invitation_limit
        @user.create_invitation(
          :sender => current_user,
          :recipient_name => @user.name,
          :recipient_email => @user.email,
          :sent_at => Time.now
        )
        @user.deliver_activation_instructions!
        flash[:success] = t('admin.users.flashs.success.create')
        redirect_to admin_root_url
      else
        render :action => :new
      end
    end
  end

  #def update
  #  if @user.update_attributes(params[:user])
  #    flash[:notice] = "Account updated!"
  #    redirect_to admin_user_path(@user)
  #  else
  #    render :action => :edit
  #  end
  #end

  protected

  def find_user
    @user = params[:id] ? User.find(params[:id]) : @current_user
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_root_url
  end
end
