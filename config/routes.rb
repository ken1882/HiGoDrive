CurrentVersion = 'v0'
Rails.application.routes.draw do
  
  # home page
  root 'static_pages#home'
  get '/index', to: 'static_pages#home'
  get '/home', to: 'static_pages#home'
  get '/signup', to: 'static_pages#signup'
  
  match '/login'  =>"api/#{CurrentVersion}/session#new",     via: [:get]
  match '/login'  => "api/#{CurrentVersion}/session#create", via: [:post]
  match '/logout' =>"api/#{CurrentVersion}/session#destroy", via: [:delete, :get]

  # API routes
  namespace 'api' do
    namespace "#{CurrentVersion}" do
      resources :handshake
      resources :users
      resources :tasks
      resources :reviews

      post '/checkusername', to: 'users#checkusername'
      post '/checkemail', to: 'users#checkemail'
      post '/checkphone', to: 'users#checkphone'
      post '/currentuser', to: 'session#index'
      post '/forgotpassword', to: 'users#forgot_password'
      post '/resetpassword', to: 'users#reset_password'
      
      match '/users/search/:username', to: 'users#peak', via: [:get]
      
      put '/user/update', to: 'users#update'
      post '/user/setpos', to: 'users#setpos'
      get '/user/getpos', to: 'users#getpos'
      
      get '/mytasks', to: 'tasks#user_tasks'
      
    end
  end
  
  # 404
  get '*unmatched_route', to: 'application#not_found'
end
