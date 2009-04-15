class Admin::UsersController < Admin::AdminController
  before_filter :find_user, :only => [:show, :edit, :update]

  def index
    @users = User.all
  end

  def show
  end

  #def new
  #  @user = User.new
  #end

  #def edit
  #end

  #def create
  #  @user = User.new(params[:user])
  #  if @user.save
  #    flash[:notice] = "Account registered!"
  #    redirect_to admin_user_path(@user)
  #  else
  #    render :action => :new
  #  end
  #end

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
    @user = params[:id] ? User.find_by_login(params[:id]) : @current_user
  end
end
