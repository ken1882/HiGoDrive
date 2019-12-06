CurrentVersion = 'v0'
Rails.application.routes.draw do

  # home page
  root 'static_pages#home'
  get '/index', to: 'static_pages#home'
  get '/home', to: 'static_pages#home'

  match '/users' => "api/#{CurrentVersion}/users#show", via: [:get]
  match '/user'  => "api/#{CurrentVersion}/users#show", via: [:get]

  match '/login'  =>"api/#{CurrentVersion}/session#new",     via: [:get]
  match '/login'  => "api/#{CurrentVersion}/session#create", via: [:post]
  match '/logout' =>"api/#{CurrentVersion}/session#destroy", via: [:delete, :get]

  # API routes
  namespace 'api' do
    namespace "#{CurrentVersion}" do
      resources :handshake
      resources :users
      post '/checkusername', to: 'users#checkusername'
      post '/checkemail', to: 'users#checkemail'
      post '/currentuser', to: 'session#index'
      put '/user/update', to: 'users#update'
      put '/users/update', to: 'users#update'
    end
  end
  
  # 404
  get '*unmatched_route', to: 'application#not_found'
end
