class Admin::UsersController < Admin::AdminController
  before_filter :find_user, :only => [:show,:edit,:update]
  
  def index
    @users = User.all
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Account registered!"
      redirect_to admin_user_path(@user)
    else
      render :action => :new
    end
  end

  def show
    # @user = params[:id] ? User.find(params[:id]) : @current_user
  end

  def edit
    # @user = User.find(params[:id])   
  end
  
  def update
    # @user = User.find(params[:id])   
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to admin_user_path(@user)
    else
      render :action => :edit
    end
  end

  private
  
  def find_user
    @user = params[:id] ? User.find(params[:id]) : @current_user
  end

end
