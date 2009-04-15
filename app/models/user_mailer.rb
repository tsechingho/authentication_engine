class UserMailer < ActionMailer::Base
  default_url_options[:host] = NOTIFIER[:host]

  def activation_instructions(user)
    subject       I18n.t('user_mailer.titles.activation_instructions')
    from          "#{NOTIFIER[:name]} <#{NOTIFIER[:email]}>"
    recipients    user.email
    sent_on       Time.now
    body          :account_activation_url => register_url(user.perishable_token)
  end

  def activation_confirmation(user)
    subject       I18n.t('user_mailer.titles.activation_confirmation')
    from          "#{NOTIFIER[:name]} <#{NOTIFIER[:email]}>"
    recipients    user.email
    sent_on       Time.now
    body          :root_url => root_url
  end

  def password_reset_instructions(user)
    subject       I18n.t('user_mailer.titles.password_reset_instructions')
    from          "#{NOTIFIER[:name]} <#{NOTIFIER[:email]}>"
    recipients    user.email
    sent_on       Time.now
    body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
  end

  def invitation(invitation, signup_url)
    subject       I18n.t('user_mailer.titles.user_invitation')
    from          "#{NOTIFIER[:name]} <#{NOTIFIER[:email]}>"
    recipients    invitation.recipient_email
    sent_on       Time.now
    body          :invitation => invitation, :signup_url => signup_url

    invitation.update_attribute(:sent_at, Time.now)
  end

  def invitation_request(invitation)
    subject       I18n.t('user_mailer.titles.user_invitation_request')
    from          invitation.applicant_email
    recipients    "#{ADMIN[:name]} <#{ADMIN[:email]}>"
    sent_on       Time.now
    body          :invitation => invitation
  end
end
