class InvitationsController < ApplicationController
  # before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user

  def new
    @invitation = Invitation.new
    # constrain invitations to a specific site
    # @invitation.site_id = current_site.id
  end
  
  def create
    @invitation = Invitation.new(params[:invitation])
    @invitation.sender = current_user
    if @invitation.save
      if current_user
        Notifier.deliver_invitation(@invitation, accept_url(@invitation.token))
        flash[:notice] = "Thank you, invitation sent."
        redirect_to '/'
      else
        flash[:notice] = "Thank you, we will notify you when we are ready."
        redirect_to '/'
      end
    else
      render :action => 'new'
    end
  end
end
