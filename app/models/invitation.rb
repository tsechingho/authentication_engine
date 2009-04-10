class Invitation < ActiveRecord::Base

  # Authorization plugin
  # acts_as_authorizable

  belongs_to :sender, :class_name => 'User'
  has_one :recipient, :class_name => 'User'

  validates_presence_of :recipient_email
  validate :recipient_is_not_registered
  validate :sender_has_invitations, :if => :sender

  before_create :generate_token
  before_create :decrement_sender_count, :if => :sender

  private

  def recipient_is_not_registered
    errors.add :recipient_email, :registered if User.find_by_email(recipient_email)
  end

  def sender_has_invitations
    # debugger
    errors.add_to_base :reach_invitaion_limit unless sender.invitation_limit > 0
  end

  def generate_token
    self.token = Digest::SHA1.hexdigest([Time.now, rand].join)
  end

  def decrement_sender_count
    sender.decrement! :invitation_limit
  end
end
