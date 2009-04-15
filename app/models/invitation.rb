class Invitation < ActiveRecord::Base

  # Authorization plugin
  # acts_as_authorizable

  belongs_to :sender, :class_name => 'User'
  has_one :recipient, :class_name => 'User'

  attr_accessor :applicant_name
  attr_accessor :applicant_email

  validates_presence_of :applicant_email, :unless => :sender
  validates_length_of :applicant_email, :within => 6..100, :unless => :sender
  validates_format_of :applicant_email, :with => email_regex, :message => :invalid, :unless => :sender
  validate :applicant_is_not_invited, :unless => :sender
  validate :applicant_is_not_registered, :unless => :sender

  validates_presence_of :recipient_email, :if => :sender
  validates_length_of :recipient_email, :within => 6..100, :if => :sender
  validates_format_of :recipient_email, :with => email_regex, :message => :invalid, :if => :sender
  validates_uniqueness_of :recipient_email, :case_sensitive => false, :if => :sender
  validate :recipient_is_not_registered, :if => :sender
  validate :sender_has_invitations, :if => :sender

  before_create :generate_token
  before_create :decrement_sender_count, :if => :sender

  def applicant_name
    recipient_name
  end

  def applicant_name=(name)
    self.recipient_name = name
  end

  def applicant_email
    recipient_email
  end

  def applicant_email=(email)
    self.recipient_email = email
  end

  private

  def recipient_is_not_registered
    errors.add :recipient_email, :registered if User.find_by_email(recipient_email)
  end

  def applicant_is_not_registered
    errors.add :applicant_email, :registered if User.find_by_email(applicant_email)
  end

  def applicant_is_not_invited
    errors.add :applicant_email, :taken if Invitation.find_by_recipient_email(applicant_email)
  end

  def sender_has_invitations
    errors.add_to_base :reach_invitation_limit unless sender.invitation_limit > 0
  end

  def generate_token
    self.token = Digest::SHA1.hexdigest([Time.now, rand].join)
  end

  def decrement_sender_count
    sender.decrement! :invitation_limit
  end

  def email_regex
    return @email_regex if @email_regex
    email_name_regex  = '[\w\.%\+\-]+'
    domain_head_regex = '(?:[A-Z0-9\-]+\.)+'
    domain_tld_regex  = '(?:[A-Z]{2,4}|museum|travel)'
    @email_regex = /\A#{email_name_regex}@#{domain_head_regex}#{domain_tld_regex}\z/i
  end
end
