CurrentVersion = 'v0'
Rails.application.routes.draw do

  resources :tasks
  # home page
  root 'pages#index'
  get '/index', to: 'pages#index'

  get '/signup', to: 'pages#signup'
  get '/login', to: 'pages#login'

  get '/home', to: 'pages#home'
  get '/search', to: 'pages#search'
  get '/task', to: 'pages#task'
  get '/user', to: 'pages#userInfo'

  get '/account-recovery', to: 'pages#passwordForget'
  get '/account-recovery/reset', to: 'pages#passwordReset'

  match '/users' => "api/#{CurrentVersion}/users#show", via: [:get]
  # match '/user'  => "api/#{CurrentVersion}/users#show", via: [:get]

  match '/login'  => "api/#{CurrentVersion}/session#create", via: [:post]
  match '/logout' =>"api/#{CurrentVersion}/session#destroy", via: [:delete, :get]

  # API routes
  namespace 'api' do
    namespace "#{CurrentVersion}" do
      resources :handshake
      resources :users
      resources :tasks

      post '/checkusername', to: 'users#checkusername'
      post '/checkemail', to: 'users#checkemail'
      post '/currentuser', to: 'session#index'
      post '/forgotpassword', to: 'users#forgot_password'
      post '/resetpassword', to: 'users#reset_password'

      put '/user/update', to: 'users#update'
      post '/user/setpos', to: 'users#setpos'
      get '/user/getpos', to: 'users#getpos'
      get '/search', to: 'users#show'
    end
  end

  # 404
  get '*unmatched_route', to: 'application#not_found'
end
