CurrentVersion = 'v0'
Rails.application.routes.draw do
  get 'session/new'
  # home page
  root 'static_pages#home'
  get '/index', to: 'static_pages#home'
  get '/home', to: 'static_pages#home'
  get '/help', to: 'static_pages#help'
  get '/signup', to: 'static_pages#signup'
  get '/login', to: 'session#new'
  post '/login', to: 'session#create'
  delete '/logout', to: 'session#destroy'
  get '/logout', to: 'session#destroy'

  match '/users' => "api/#{CurrentVersion}/users#show", via: [:get]
  match '/user'  => "api/#{CurrentVersion}/users#show", via: [:get]

  # API routes
  namespace 'api' do
    namespace "#{CurrentVersion}" do
      resources :handshake
      resources :users
      post '/checkusername', to: 'users#checkusername'
      post '/checkemail', to: 'users#checkemail'
    end
  end
  
  # 404
  get '*unmatched_route', to: 'application#not_found'
end
