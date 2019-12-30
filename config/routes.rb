CurrentVersion = 'v0'
Rails.application.routes.draw do
  
  resources :reports
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
      
      put '/user/update', to: 'users#update'
      post '/user/setpos', to: 'users#setpos'
      get '/user/getpos', to: 'users#getpos'
      
      match '/users/search/:username', to: 'users#peak', via: [:get]
      
      get '/mytasks', to: 'users#user_tasks'
      get '/tasks_engaging', to: 'users#tasks_engaging'
      get '/tasks_history', to: 'users#tasks_history'
      get '/next_task', to: 'tasks#next_task'

      post '/task/accept', to: 'tasks#accept'
      post '/task/engage', to: 'tasks#engage'
      post '/task/reject', to: 'tasks#reject'
      post '/task/finish', to: 'tasks#finish'
      post '/task/report', to: 'tasks#report'

      match '/tasks/:task_id/reviews/:id', to: 'reviews#show', via: [:get]
      match '/tasks/:task_id/reviews', to: 'reviews#index', via: [:get]
      match '/tasks/:task_id/reviews', to: 'reviews#create', via: [:post]

      match '/tasks/:task_id/reports/:id', to: 'reports#show', via: [:get]
      match '/tasks/:task_id/reports', to: 'reports#index', via: [:get]
      match '/tasks/:task_id/reports', to: 'reports#create', via: [:post]
    end
  end
  
  # 404
  get '*unmatched_route', to: 'application#not_found'
end
