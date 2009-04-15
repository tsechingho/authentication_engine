class Admin::AdminController < ApplicationController
  before_filter :require_user
  # if you are using simple admin boolean on user
  before_filter :require_admin
  # if you are using authorization_engine
  # permit 'root or admin'

  layout 'admin'

  protected

  def beta_signup
    redirect_to admin_root_url unless REGISTRATION[:beta]
  end
end
