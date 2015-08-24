Houndapp::Application.routes.draw do
  namespace :admin do
    DashboardManifest::DASHBOARDS.each do |dashboard_resource|
      resources(
        dashboard_resource,
        controller: "application",
        resource_class: dashboard_resource,
      )
    end

    root to: "application#index", resource_class: :bulk_customers
  end

  mount Resque::Server, at: "/queue"
  mount JasmineRails::Engine => "/specs" if defined?(JasmineRails)
  mount Split::Dashboard, at: "split"

  get "/auth/github/callback", to: "sessions#create"
  get "/sign_out", to: "sessions#destroy"
  get "/configuration", to: "pages#configuration"
  get "/faq", to: "pages#show", id: "faq"

  resource :account, only: [:show, :update]
  resources :builds, only: [:create]

  resources :repos, only: [:index] do
    with_options(defaults: { format: :json }) do
      resource :activation, only: [:create]
      resource :deactivation, only: [:create]
      resource :subscription, only: [:create, :destroy]
    end
  end

  with_options(defaults: { format: :json }) do
    resource :credit_card, only: [:update]
    resources :repo_syncs, only: [:index, :create]
    resource :user, only: [:show]
  end

  %w(404 422 500).each do |status_code|
    get status_code, to: "errors#show", code: status_code
  end

  root to: "home#index"
end
