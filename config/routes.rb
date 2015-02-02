Houndapp::Application.routes.draw do
  mount Resque::Server, at: "/queue"
  mount JasmineRails::Engine => "/specs" if defined?(JasmineRails)

  get "/auth/github/callback", to: "sessions#create"
  get "/sign_out", to: "sessions#destroy"
  get "/configuration", to: "pages#configuration"
  get "/faq", to: "pages#show", id: "faq"

  resource :account, only: [:show]
  resources :builds, only: [:create]
  resource :credit_card, only: [:update]

  resources :repos, only: [:index] do
    resource :activation, only: [:create]
    resource :deactivation, only: [:create]
    resource :subscription, only: [:create, :destroy]
  end

  resources :repo_syncs, only: [:index, :create]
  resource :user, only: [:show]

  root to: "home#index"
end
