Houndapp::Application.routes.draw do
  root to: 'home#index'

  resources :builds, only: [:create, :show]
  resources :repo_activations, only: [:create, :destroy]
  resources :repos, only: [:index, :update] do
    get 'sync', on: :collection
    get 'events', on: :collection
  end

  get '/auth/github/callback', to: 'sessions#create'
  get '/sign_in', to: 'sessions#new'

  get '/sign_out', to: 'sessions#destroy'
end
