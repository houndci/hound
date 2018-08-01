Houndapp::Application.routes.draw do
  namespace :admin do
    DashboardManifest::DASHBOARDS.each do |dashboard_resource|
      resources dashboard_resource
    end

    resources :masquerades, param: :username, only: [:show, :destroy]
    root controller: DashboardManifest::ROOT_DASHBOARD, action: :index
  end

  mount Resque::Server, at: "/queue"

  get "/auth/github/callback", to: "sessions#create"
  get "/sign_out", to: "sessions#destroy"
  get "/configuration", to: redirect(ENV.fetch("DOCS_URL"), status: 302)
  get "/faq", to: redirect(ENV.fetch("FAQ_URL"), status: 302)
  get "/help", to: redirect(ENV.fetch("HELP_URL"), status: 302)

  resource :account, only: [:show, :update]
  resources :builds, only: [:create, :index]
  resources :owners, only: [:update]
  resources :plans, only: [:index]
  resources :deleted_subscriptions, only: [:create]
  resources :github_events, only: [:create]

  resources :repos, only: [:index] do
    with_options(defaults: { format: :json }) do
      resource :activation, only: [:create]
      resource :deactivation, only: [:create]
      resource :subscription, only: [:create, :update, :destroy]
    end

    resources :rebuilds, only: [:create]
  end

  with_options(defaults: { format: :json }) do
    resource :credit_card, only: [:update]
    resources :repo_syncs, only: [:create]
    resource :user, only: [:show]
  end

  %w(404 422 500).each do |status_code|
    get status_code, to: "errors#show", code: status_code
  end

  root to: "home#index"
end
