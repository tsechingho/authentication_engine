class Admin::AdminController < ApplicationController
  before_filter :require_user
  before_filter :require_admin
  layout 'admin'

  # permit 'root'
   
end
