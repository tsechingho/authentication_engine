ActionController::Routing::Routes.draw do |map|

  map.resource :user_session
  map.resource :account, :controller => "users"
  map.resources :users
  map.resources :password_resets
  
  map.namespace :admin do |admin|
    admin.root :controller => 'users'
  end
  
  
end
