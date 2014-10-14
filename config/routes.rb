Houndapp::Application.routes.draw do
  mount Resque::Server, at: "/queue"
  mount StripeEvent::Engine => "/stripe-event"

  get "/auth/github/callback", to: "sessions#create"
  get "/sign_out", to: "sessions#destroy"
  get "/configuration", to: "application#configuration"

  get "/faq", to: "pages#show", id: "faq"

  resource :account, only: [:show]
  resources :builds, only: [:create]

  resources :repos, only: [:index] do
    resource :activation, only: [:create]
    resource :deactivation, only: [:create]
    resource :subscription, only: [:create, :destroy]
  end

  resources :repo_syncs, only: [:index, :create]
  resource :user, only: [:show]

  root to: "home#index"
end
