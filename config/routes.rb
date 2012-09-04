Cupidhub::Application.routes.draw do
  get '/auth/:provider/callback' => 'authentication#create'
  get "/auth/:provider/failure" => 'authentication#failure'
  get '/auth/destroy' => "authentication#destroy"

  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config
  resources :hackers
end
