ActionController::Routing::Routes.draw do |map|
  map.resource :user_session, :only => [:create]
  map.login '/login', :controller => 'user_sessions', :action => 'new', :conditions => { :method => :get }
  map.logout '/logout', :controller => 'user_sessions', :action => 'destroy', :conditions => { :method => [:get, :delete] }

  if REGISTRATION[:private] or REGISTRATION[:requested] or REGISTRATION[:public]
    map.resource :account, :controller => "users", :only => [:show, :create, :edit, :update]
  else
    map.resource :account, :controller => "users", :only => [:show, :edit, :update]
  end
  map.resources :password_resets, :only => [:new, :edit, :create, :update]

  map.resources :invitations, :only => [:new, :create], :collection => {:apply => :get} if REGISTRATION[:private] and REGISTRATION[:requested]
  map.resources :invitations, :only => [:new, :create] if REGISTRATION[:private] and !REGISTRATION[:requested]
  map.resources :invitations, :only => [:create], :collection => {:apply => :get} if !REGISTRATION[:private] and REGISTRATION[:requested]
  map.accept '/accept/:invitation_token', :controller => 'users', :action => 'new', :conditions => { :method => :get }, :invitation_token => nil if REGISTRATION[:private] or REGISTRATION[:requested]

  map.signup '/signup', :controller => 'users', :action => 'new', :conditions => { :method => :get } if REGISTRATION[:public]

  if REGISTRATION[:limited] or REGISTRATION[:public]
    map.register '/register/:activation_code', :controller => 'activations', :action => 'new', :conditions => { :method => :get }, :activation_code => nil
    map.activate '/activate/:id', :controller => 'activations', :action => 'create', :conditions => { :method => :post }
  end

  # map.resources :users, :only => [:show, :edit, :update]

  map.namespace :admin do |admin|
    admin.root :controller => 'users'
    # admin.resource :account, :controller => 'users'
    if REGISTRATION[:limited]
      admin.resources :users, :only => [:index, :show, :new, :create]
    else
      admin.resources :users, :only => [:index, :show]
    end
    admin.resources :invitations, :only => [:index], :member => { :deliver => :put }
  end
end
