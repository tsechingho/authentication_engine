class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.validates_length_of_login_field_options = {:within => 3..100, :on => :update, :if => :validate_login_with_openid?}
    c.validates_format_of_login_field_options = {:with => /\A\w[\w\.\-_@ ]+\z/, :on => :update, :message => I18n.t('authlogic.error_messages.login_invalid', :default => "should use only letters, numbers, spaces, and .-_@ please."), :if => :validate_login_with_openid?}
    c.validates_uniqueness_of_login_field_options = {:on => :update, :case_sensitive => false, :scope => validations_scope, :if => "#{login_field}_changed?".to_sym}
    
    c.validates_length_of_password_field_options = {:minimum => 4, :on => :update, :if => :require_password?}
    c.validates_confirmation_of_password_field_options = {:minimum => 4, :on => :update, :if => (password_salt_field ? "#{password_salt_field}_changed?".to_sym : nil)}
    c.validates_length_of_password_confirmation_field_options = {:minimum => 4, :on => :update, :if => :require_password?}
  end

  validates_length_of :login, :within => 3..100, :on => :create, :if => :invited_and_require_password?
  validates_format_of :login, :with => /\A\w[\w\.\-_@ ]+\z/, :on => :create, :message => I18n.t('authlogic.error_messages.login_invalid', :default => "should use only letters, numbers, spaces, and .-_@ please."), :if => :invited_and_require_password?
  validates_uniqueness_of :login, :on => :create, :case_sensitive => false, :if => :invited_and_require_password?

  validates_length_of :password, :minimum => 4, :on => :create, :if => :invited_and_require_password?
  validates_confirmation_of :password_confirmation, :on => :create, :if => :invited_and_require_password?
  validates_length_of :password_confirmation, :minimum => 4, :on => :create, :if => :invited_and_require_password?

  validates_presence_of :name
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

  # check when user's credentials changed
  def validate_login_with_openid?
    validate_password_with_openid?
  end

  # We need to save with block to prevent double render/redirect error.
  def save_with_block(logged, &block)
    if logged
      result = save_without_session_maintenance
      yield(result) if block_given?
      result
    else
      save(true, &block)
    end
  end

  # We need to distinguish general signup or invitee singup
  def signup!(user, prompt, &block)
    return save(true, &block) if openid_complete?
    return signup_as_invitee!(user, prompt, &block) if user and user[:invitation_id]
    signup_without_credentials!(user, &block)
  end

  # Since invitee need to be activated with credentials,
  # we save with block.
  def signup_as_invitee!(user, prompt, &block)
    self.attributes = user if user
    logged = prompt and validate_password_with_openid?
    save_with_block(logged, &block)
  end

  # Since users have to activate themself with credentials,
  # we should signup without session maintenance and save with block.
  def signup_without_credentials!(user, &block)
    unless user.blank?
      self.name = user[:name]
      self.email = user[:email]
    end
    # only one user can be admin
    self.admin = true if User.count == 0
    save_with_block(true, &block)
  end

  # Since openid_identifier= will trigger openid authentication,
  # we save with block.
  def activate!(user, prompt, &block)
    unless user.blank?
      self.login = user[:login]
      self.password = user[:password]
      self.password_confirmation = user[:password_confirmation]
      self.openid_identifier = user[:openid_identifier]
    end
    logged = prompt and validate_password_with_openid?
    save_with_block(logged, &block)
  end

  # Since password reset doesn't need to change openid_identifier,
  # we save without block as usual.
  def reset_password!(user)
    self.password = user[:password]
    self.password_confirmation = user[:password_confirmation]
    save
  end

  # we only have name and email for a new created user
  def to_param
    "#{id}-#{name.parameterize}"
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
