Rails.application.routes.draw do
  # API routes
  namespace 'api' do
    namespace 'v0' do
      resources :handshake
      resources :users
    end
  end
  # home page
  root :controller => 'homepage', :action => :index
  # 404
  get '*unmatched_route', to: 'application#not_found'
end
