Houndapp::Application.routes.draw do
  root to: 'home#index'

  get '/auth/github/callback', to: 'sessions#create'
  get '/sign_in', to: 'sessions#new'
  get '/sign_out', to: 'sessions#destroy'
  get '/configuration', to: 'application#configuration'

  resources :builds, only: [:create]
  resources :repos, only: [:index] do
    resource :activation, only: [:create]
    resource :deactivation, only: [:create]
  end
  resources :repo_syncs, only: [:index, :create]
end
