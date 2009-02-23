module AuthenticationSystem
  protected
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.user
    end
  
    def require_user
      unless current_user
        store_location
        flash[:notice] = "You must be logged in to access this page"
        redirect_to new_user_session_url
        return false
      end
    end

    def require_no_user
      if current_user
        store_location
        flash[:notice] = "You must be logged out to access this page"
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
    def admin?; current_user && current_user.admin?; end

    # Before filter to limit certain actions to administrators
    def require_admin
      unless admin?
        flash[:error] = "Sorry, only administrators can do that."
        redirect_to '/'
      end
    end

    # Inclusion hook to make #current_user and #current_user_session
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_user, :current_user_session, :admin? if base.respond_to? :helper_method
    end

end
