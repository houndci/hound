Houndapp::Application.routes.draw do
  root to: 'home#index'

  get '/auth/github/callback', to: 'sessions#create'
  get '/sign_in', to: 'sessions#new'
  get '/sign_out', to: 'sessions#destroy'

  resources :builds, only: [:create, :show]
  resources :repos, only: [:index, :update]
  resources :repo_activations, only: [:create, :destroy]
  resources :repo_syncs, only: [:index, :create]
end
