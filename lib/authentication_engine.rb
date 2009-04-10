module AuthenticationEngine
  module ClassMethods
    
  end

  module InstanceMethods
    protected

    def current_user_session
      @current_user_session ||= UserSession.find
    end

    def current_user
      @current_user ||= current_user_session && current_user_session.record
    end

    def require_user
      unless current_user
        store_location
        flash[:notice] = t('users.flashs.notices.login_required')
        redirect_to login_url
        return false
      end
    end

    def require_no_user
      if current_user
        store_location
        flash[:notice] = t('users.flashs.notices.logout_required')
        redirect_to account_url
        return false
      end
    end

    def store_location
      session[:return_to] = request.request_uri
    end

    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

    # Helper method to determine whether the current user is an administrator
    def admin?
      current_user && current_user.admin?
    end

    # Before filter to limit certain actions to administrators
    def require_admin
      unless admin?
        store_location
        flash[:error] = t('users.flashs.errors.admin_required')
        redirect_to root_url
        return false
      end
    end
  end

  # Inclusion hook to make #current_user and #current_user_session
  # available as ActionView helper methods.
  def self.included(receiver)
    receiver.extend ClassMethods
    receiver.class_eval do
      include InstanceMethods
      helper_method :current_user_session, :current_user, :admin?
      filter_parameter_logging :password, :password_confirmation
    end
  end
end