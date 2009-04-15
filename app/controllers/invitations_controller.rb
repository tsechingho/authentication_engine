class InvitationsController < ApplicationController
  before_filter :private_signup, :only => [:new, :create]
  before_filter :beta_signup, :only => [:apply, :ask]
  # require_user if only registered uses can send invites
  before_filter :require_user, :only => [:new, :create]
  # require_no_user if you want to allow public registration for access
  # before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_no_user, :only => [:apply, :request]

  # GET /invitations/new
  def new
    @invitation = Invitation.new
    # constrain invitations to a specific site
    # @invitation.site_id = current_site.id
  end

  # POST /invitations
  def create
    @invitation = Invitation.new(params[:invitation])
    @invitation.sender = current_user
    if @invitation.save
      if current_user
        UserMailer.deliver_invitation(@invitation, accept_url(@invitation.token))
        flash[:success] = t('invitations.flashs.success.create')
        redirect_to root_url
      else
        flash[:notice] = t('invitations.flashs.notice.create')
        redirect_to root_url
      end
    else
      render :action => 'new'
    end
  end

  # GET /invitations/apply
  def apply
    @invitation = Invitation.new
  end

  # POST /invitations/ask
  def ask
    @invitation = Invitation.new(params[:invitation])
    if @invitation.save
      UserMailer.deliver_invitation_request(@invitation)
      flash[:success] = t('invitations.flashs.success.ask')
      redirect_to root_url
    else
      render :action => 'apply'
    end
  end
end
