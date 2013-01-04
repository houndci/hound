Houndapp::Application.routes.draw do
  root to: 'home#index'

  get '/auth/github/callback', to: 'sessions#create'

  match 'sign_in' => 'sessions#new', as: 'sign_in'
  match 'sign_out' => 'sessions#destroy', as: 'sign_out', via: :delete
end
