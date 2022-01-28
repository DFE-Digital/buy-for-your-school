# frozen_string_literal: true

Rails.application.routes.draw do
  # DfE Sign In
  get "/auth/dfe/callback", to: "sessions#create", as: :sign_in
  get "/auth/dfe/signout", to: "sessions#destroy", as: :issuer_redirect
  delete "/auth/dfe/signout", to: "sessions#destroy", as: :sign_out
  get "/auth/failure", to: "sessions#failure"
  post "/auth/developer/callback" => "sessions#bypass_callback" if Rails.env.development?

  # Errors
  get "/404", to: "errors#not_found"
  get "/422", to: "errors#unacceptable"
  get "/500", to: "errors#internal_server_error"

  #
  # Self-Serve -----------------------------------------------------------------
  #
  root to: "home#show"

  get "dashboard", to: "dashboard#show"
  get "profile", to: "profile#show"

  # Contentful
  namespace :api do
    namespace :contentful do
      post "auth" => "base#auth"
      post "entry_updated" => "entries#changed"
      post "category" => "categories#changed"
      resources :pages, only: %i[create destroy]
    end
  end

  # NB: guard against use of back button after form validation errors
  get "/journeys/:journey/steps/:step/answers", to: redirect("/journeys/%{journey}/steps/%{step}")

  resources :design, only: %i[index show]
  resources :categories, only: %i[index]

  #
  # Framework Requests ---------------------------------------------------------
  #
  # resources :framework_requests, except: %i[delete], path: "procurement-support", path_names: { new: "new/(:step)" }
  resources :framework_requests, except: %i[delete], path: "procurement-support"
  resources :framework_request_submissions, only: %i[update show], path: "procurement-support-submissions"

  #
  # General Support Requests ---------------------------------------------------
  #
  resources :support_requests, except: %i[destroy], path: "support-requests"
  resources :support_request_submissions, only: %i[update show], path: "support-request-submissions"
  post "/submit", to: "api/support/requests#create", as: :submit_request

  resources :journeys, only: %i[show create destroy] do
    resource :specification, only: [:show]
    resources :steps, only: %i[new show edit update] do
      resources :answers, only: %i[create update]
    end
    resources :tasks, only: [:show]
  end

  namespace :preview do
    resources :entries, only: [:show]
  end

  #
  # Supported ------------------------------------------------------------------
  #
  get "support", to: "support/pages#start_page", as: :support_root

  namespace :support do
    if Features.enabled?(:incoming_emails)
      resources :document_downloads, only: %i[show]
    end
    resources :agents, only: %i[create]
    if Features.enabled?(:incoming_emails)
      resources :emails, only: %i[index show]
      resources :email_read_status, only: %i[update], param: :email_id
    end
    resources :organisations, only: %i[index]
    resources :cases, only: %i[index show edit update] do
      collection do
        namespace :migrations do
          resource :hub_case, only: %i[new create], path: "hub-case" do
            resource :preview, only: %i[new create]
          end
        end
      end
      resources :interactions, only: %i[new create show]
      scope module: :cases do
        resource :organisation, only: %i[edit update]
        resource :contact_details, only: %i[edit update]
        resource :categorisation, only: %i[edit update]
        resource :savings, only: %i[edit update]
        resource :procurement_details, only: %i[edit update]
        resources :documents, only: %i[show]
        resource :resolution, only: %i[new create]
        resource :assignment, only: %i[new create]
        resources :contracts, only: %i[edit update]
        resource :email, only: %i[create] do
          scope module: :emails do
            resource :type, only: %i[new create]
            resources :content, only: %i[edit show update], param: :template
            resources :templates, only: %i[index], param: :template
          end
        end
      end
    end
  end

  if Rails.env.development?
    require "sidekiq/web"
    mount Sidekiq::Web, at: "/sidekiq"
  end

  #
  # Common ---------------------------------------------------------------------
  #
  get "health_check" => "application#health_check"

  scope "/admin", as: "admin" do
    get "/", to: "admin#show"
    scope "/download", as: "download" do
      get "user_activity", to: "admin#download_user_activity", as: "user_activity"
      get "users", to: "admin#download_users", as: "users"
    end
  end

  # Routes any/all Contentful Pages that are mirrored in t.pages
  # if a Page with :slug cannot be found, `errors/not_found` is rendered
  #
  # 1. Keep at the bottom of routes
  # 2. If Contentful designers need to nest static pages, a second route can be defined to
  #    simulate "directory" e.g:
  #    `get ":slug_one/:slug_two", to: "pages#show"`
  #
  get ":slug", to: "pages#show"
end
