ActionController::Routing::Routes.draw do |map|
  map.resource :user_session, :only => [:create]
  map.login '/login', :controller => 'user_sessions', :action => 'new', :conditions => { :method => :get }
  map.logout '/logout', :controller => 'user_sessions', :action => 'destroy', :conditions => { :method => [:get, :delete] }

  map.resource :account, :controller => "users", :only => [:show, :create, :edit, :update]
  map.resources :password_resets, :only => [:new, :edit, :create, :update]

  map.resources :invitations, :only => [:new, :create], :collection => {:apply => :get, :ask => :post} if REGISTRATION[:private] and REGISTRATION[:beta]
  map.resources :invitations, :only => [:new, :create] if REGISTRATION[:private] and !REGISTRATION[:beta]
  map.resources :invitations, :except => :all, :collection => {:apply => :get, :ask => :post} if !REGISTRATION[:private] and REGISTRATION[:beta]
  map.accept '/accept/:invitation_token', :controller => 'users', :action => 'new', :conditions => { :method => :get } if REGISTRATION[:private] or REGISTRATION[:beta]

  if REGISTRATION[:open]
    map.signup '/signup', :controller => 'users', :action => 'new', :conditions => { :method => :get }
    map.register '/register/:activation_code', :controller => 'activations', :action => 'new', :conditions => { :method => :get }, :activation_code => nil
    map.activate '/activate/:id', :controller => 'activations', :action => 'create', :conditions => { :method => :post }
  end

  # map.resources :users, :only => [:show, :edit, :update]

  map.namespace :admin do |admin|
    admin.root :controller => 'users'
    admin.resource :account, :controller => 'users'
    admin.resources :users
    admin.resources :invitations, :member => { :deliver => :put } if REGISTRATION[:beta]
  end
end
