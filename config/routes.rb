Houndapp::Application.routes.draw do
  root to: 'repos#index'
  resources :repos, only: [:index, :show]
  resources :repo_activations, only: [:create, :destroy]

  get '/auth/github/callback', to: 'sessions#create'

  get '/sign_in', to: 'sessions#new'
  delete '/sign_out', to: 'sessions#destroy'
end
