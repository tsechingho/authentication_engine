ActionController::Routing::Routes.draw do |map|

  map.resource :user_session
  map.resource :account, :controller => "users"
  map.resources :users
  map.resources :password_resets

  map.resources :invitations
  map.accept '/accept/:invitation_token', :controller => 'users', :action => 'new'
  
  map.namespace :admin do |admin|
    admin.root :controller => 'users'
    admin.resource :account, :controller => "users"
    admin.resources :users
    admin.resources :invitations, :member => {:deliver => :put} 
  end
  
  
end
