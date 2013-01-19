Houndapp::Application.routes.draw do
  root to: 'repos#index'
  resources :repos, only: [:index]

  get '/auth/github/callback', to: 'sessions#create'

  get '/sign_in', to: 'sessions#new'
  delete '/sign_out', to: 'sessions#destroy'
end
