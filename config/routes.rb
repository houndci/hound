Houndapp::Application.routes.draw do
  root to: 'repos#index'

  resources :builds, only: [:create]
  resources :repo_activations, only: [:create, :destroy]
  resources :repos, only: [:index, :edit, :update] do
    get 'sync', on: :collection
  end

  get '/auth/github/callback', to: 'sessions#create'
  get '/sign_in', to: 'sessions#new'

  delete '/sign_out', to: 'sessions#destroy'
end
