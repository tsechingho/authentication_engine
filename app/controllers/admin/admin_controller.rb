class Admin::AdminController < ApplicationController
  before_filter :require_user
  # if you are using simple admin boolean on user
  before_filter :require_admin
  # if you are using authorization_engine
  # permit 'root or admin'

  layout 'admin'
end
