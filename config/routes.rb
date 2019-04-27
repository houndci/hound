require "sidekiq/web"

Sidekiq::Web.use Rack::Auth::Basic do |_, password|
  ActiveSupport::SecurityUtils.secure_compare(
    ::Digest::SHA256.hexdigest(password),
    ::Digest::SHA256.hexdigest(ENV["JOB_ADMIN_PASSWORD"]),
  )
end

Houndapp::Application.routes.draw do
  namespace :admin do
    DashboardManifest::DASHBOARDS.each do |dashboard_resource|
      resources dashboard_resource
    end

    resources :masquerades, param: :username, only: [:show, :destroy]
    root controller: DashboardManifest::ROOT_DASHBOARD, action: :index
  end

  mount Sidekiq::Web, at: "/jobs"
  mount Split::Dashboard, at: "/split"

  get "/auth/github/callback", to: "sessions#create"
  get "/sign_out", to: "sessions#destroy"
  get "/configuration", to: redirect(ENV.fetch("DOCS_URL"), status: 302)
  get "/docs", to: redirect(ENV.fetch("DOCS_URL"), status: 302)
  get "/documentation", to: redirect(ENV.fetch("DOCS_URL"), status: 302)
  get "/faq", to: redirect(ENV.fetch("FAQ_URL"), status: 302)
  get "/help", to: redirect(ENV.fetch("HELP_URL"), status: 302)
  get "/update_billing", to: "application#update_billing"

  resource :account, only: [:show, :update]
  resources :builds, only: [:create, :index]
  resources :deleted_subscriptions, only: [:create]
  resources :github_events, only: [:create]
  resources :owners, only: [:update]
  resources :plans, only: [:index]
  resource :setup, only: [:show]

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
