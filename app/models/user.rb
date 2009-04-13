class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.validates_length_of_password_field_options = {:minimum => 4, :on => :update, :if => :require_password?}
    c.validates_confirmation_of_password_field_options = {:minimum => 4, :on => :update, :if => (password_salt_field ? "#{password_salt_field}_changed?".to_sym : nil)}
    c.validates_length_of_password_confirmation_field_options = {:minimum => 4, :on => :update, :if => :require_password?}
  end

  # # Authorization plugin
  # acts_as_authorized_user
  # acts_as_authorizable
  # authorization plugin may need this too, which breaks the model
  # attr_accesibles need to merged; this resets it
  # attr_accessible :role_ids

  validate :normalize_openid_identifier
  validates_uniqueness_of :openid_identifier, :allow_blank => true
  # validates_length_of :email, :minimum => 500, :unless => "true"

  validates_uniqueness_of :invitation_id, :allow_nil => true

  attr_accessible :name, :login, :email, :password, :password_confirmation, :openid_identifier, :invitation_id

  has_many :sent_invitations, :class_name => 'Invitation', :foreign_key => 'sender_id'
  belongs_to :invitation

  before_create :set_invitation_limit
  before_destroy :deny_admin_suicide

  def invitation_token
    invitation.token if invitation
  end

  def invitation_token=(token)
    self.invitation = Invitation.find_by_token(token)
  end

  def signup!(user)
    self.name = user[:name]
    self.login = user[:login]
    self.email = user[:email]
    self.invitation_id = user[:invitation_id]
    # only one user can be admin
    self.admin = true if User.count == 0
    save_without_session_maintenance
  end

  def activate!(user)
    self.password = user[:password]
    self.password_confirmation = user[:password_confirmation]
    self.openid_identifier = user[:openid_identifier]
    save
  end

  def to_param
    login.parameterize
  end

  def deliver_activation_instructions!
    # skip reset perishable token since we don't set roles in signup!
    reset_perishable_token!
    UserMailer.deliver_activation_instructions(self)
  end

  def deliver_activation_confirmation!
    reset_perishable_token!
    UserMailer.deliver_activation_confirmation(self)
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    UserMailer.deliver_password_reset_instructions(self)
  end

  private

  def normalize_openid_identifier
    begin
      self.openid_identifier = OpenIdAuthentication.normalize_identifier(openid_identifier) if !openid_identifier.blank?
    rescue OpenIdAuthentication::InvalidOpenId => e
      errors.add(:openid_identifier, e.message)
    end
  end

  def set_invitation_limit
    self.invitation_limit = 5
  end

  # one admin at least
  def deny_admin_suicide
    #raise 'admin suicided' if User.count(&:admin) <= 1
  end
end
