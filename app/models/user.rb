class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.validates_length_of_password_field_options = {:minimum => 4, :on => :update, :if => :require_password?}
    c.validates_confirmation_of_password_field_options = {:minimum => 4, :on => :update, :if => (password_salt_field ? "#{password_salt_field}_changed?".to_sym : nil)}
    c.validates_length_of_password_confirmation_field_options = {:minimum => 4, :on => :update, :if => :require_password?}
  end

  validates_length_of :password, :minimum => 4, :on => :create, :if => :invited_and_require_password?
  validates_confirmation_of :password_confirmation, :on => :create, :if => :invited_and_require_password?
  validates_length_of :password_confirmation, :minimum => 4, :on => :create, :if => :invited_and_require_password?
  validates_uniqueness_of :invitation_id, :allow_nil => true

  attr_accessible :name, :email, :login, :password, :password_confirmation, :openid_identifier, :invitation_id

  # # Authorization plugin
  # acts_as_authorized_user
  # acts_as_authorizable
  # authorization plugin may need this too, which breaks the model
  # attr_accesibles need to merged; this resets it
  # attr_accessible :role_ids

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

  def invited_and_require_password?
    !invitation_id.blank? && validate_password_with_openid?
  end

  # We need to distinguish general signup or invitee singup
  def signup!(user, &block)
    return save(true, &block) if openid_complete?
    return signup_as_invitee!(user, &block) if user and user[:invitation_id]
    signup_without_credentials!(user, &block)
  end

  # Since invitee need to be activated with credentials,
  # we save with &block to prevent double render/redirect error.
  def signup_as_invitee!(user, &block)
    self.attributes = user if user
    save(true, &block)
  end

  # Since users have to activate themself with credentials,
  # we should signup without session maintenance and keep block style.
  def signup_without_credentials!(user, &block)
    unless user.blank?
      self.name = user[:name]
      self.login = user[:login]
      self.email = user[:email]
    end
    # only one user can be admin
    self.admin = true if User.count == 0
    result = save_without_session_maintenance
    yield(result) if block_given?
    result
  end

  # Since openid_identifier= will trigger openid authentication,
  # we need to save with block to prevent double render/redirect error.
  def activate!(user, &block)
    unless user.blank?
      self.password = user[:password]
      self.password_confirmation = user[:password_confirmation]
      self.openid_identifier = user[:openid_identifier]
    end
    save(true, &block)
  end

  # Since password reset doesn't need to change openid_identifier,
  # we save without block as usual.
  def reset_password!(user)
    self.password = user[:password]
    self.password_confirmation = user[:password_confirmation]
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

  def set_invitation_limit
    self.invitation_limit = 5
  end

  def attributes_to_save
    attrs_to_save = attributes.clone.delete_if do |k, v|
      [:password, crypted_password_field, password_salt_field, :persistence_token, :perishable_token, :single_access_token, :login_count, 
        :failed_login_count, :last_request_at, :current_login_at, :last_login_at, :current_login_ip, :last_login_ip, :created_at,
        :updated_at, :lock_version, :admin, :invitation_limit].include?(k.to_sym)
    end
    attrs_to_save.merge!(:password => password, :password_confirmation => password_confirmation)
  end

  # one admin at least
  def deny_admin_suicide
    #raise 'admin suicided' if User.count(&:admin) <= 1
  end
end
