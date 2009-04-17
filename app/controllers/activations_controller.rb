class ActivationsController < ApplicationController
  before_filter :open_signup, :only => [:new, :create]
  before_filter :require_no_user, :only => [:new, :create]

  # GET /register/:activation_code
  def new
    @user = User.find_using_perishable_token(params[:activation_code], 1.week) || (raise Exception)
    #raise Exception if @user.active?
  rescue Exception => e
    redirect_to root_url
  end

  # POST /activate/:id
  def create
    @user = User.find(params[:id])
    #raise Exception if @user.active?

    @user.activate!(params[:user], ACTIVATION[:prompt]) do |result|
      if result
        @user.deliver_activation_confirmation!
        if ACTIVATION[:prompt]
          flash[:success] = t('activations.flashs.success.prompt')
          redirect_to login_url
        else
          flash[:success] = t('activations.flashs.success.create')
          redirect_to account_url
        end
      else
        render :action => :new
      end
    end
  rescue Exception => e
    redirect_to root_url
  end
end