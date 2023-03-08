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

  resource :cookie_preferences, only: %i[show edit update]

  # Contentful
  namespace :api do
    namespace :contentful do
      post "auth" => "base#auth"
      post "entry_updated" => "entries#changed"
      post "category" => "categories#changed"
      resources :pages, only: %i[create destroy]
    end

    namespace :find_a_framework do
      post "framework" => "frameworks#changed"
    end

    namespace :user_journeys do
      post "step" => "step#create"
    end
  end

  # NB: guard against use of back button after form validation errors
  get "/journeys/:journey/steps/:step/answers", to: redirect("/journeys/%{journey}/steps/%{step}")

  resources :design, only: %i[index show]
  resources :feedback, only: %i[new show create edit update]

  #
  # Framework Requests ---------------------------------------------------------
  #
  resources :framework_requests, only: %i[index show], path: "procurement-support" do
    scope module: "framework_requests" do
      collection do
        post "/start", to: "start#create"

        get "/energy_request", to: "energy_request#index"
        post "/energy_request", to: "energy_request#create"

        get "/energy_request_about", to: "energy_request_about#index"
        post "/energy_request_about", to: "energy_request_about#create"

        get "/energy_bill", to: "energy_bill#index"
        post "/energy_bill", to: "energy_bill#create"

        get "/energy_alternative", to: "energy_alternative#index"
        post "/energy_alternative", to: "energy_alternative#create"

        get "/sign_in", to: "sign_in#index"
        post "/sign_in", to: "sign_in#create"

        get "/confirm_sign_in", to: "confirm_sign_in#index"
        post "/confirm_sign_in", to: "confirm_sign_in#create"

        get "/select_organisation", to: "select_organisations#index"
        post "/select_organisation", to: "select_organisations#create"

        get "/organisation_type", to: "organisation_types#index"
        post "/organisation_type", to: "organisation_types#create"

        get "/search_for_organisation", to: "search_for_organisations#index"
        post "/search_for_organisation", to: "search_for_organisations#create"

        get "/confirm_organisation", to: "confirm_organisations#index"
        post "/confirm_organisation", to: "confirm_organisations#create"

        get "/name", to: "names#index"
        post "/name", to: "names#create"

        get "/email", to: "emails#index"
        post "/email", to: "emails#create"

        get "/bill_uploads", to: "bill_uploads#index"
        post "/bill_uploads", to: "bill_uploads#create"
        get "(:id)/bill_uploads/list", to: "bill_uploads#list", as: "list_bill_uploads"
        post "(:id)/bill_uploads/upload", to: "bill_uploads#upload", as: "upload_bill_uploads"
        delete "(:id)/bill_uploads/remove", to: "bill_uploads#remove", as: "remove_bill_uploads"

        get "/message", to: "messages#index"
        post "/message", to: "messages#create"

        get "/procurement_amount", to: "procurement_amounts#index"
        post "/procurement_amount", to: "procurement_amounts#create"

        get "/special_requirements", to: "special_requirements#index"
        post "/special_requirements", to: "special_requirements#create"
      end
      member do
        resource :select_organisation, only: %i[edit update], as: :framework_request_select_organisation
        resource :organisation_type, only: %i[edit update], as: :framework_request_organisation_type
        resource :search_for_organisation, only: %i[edit update], as: :framework_request_search_for_organisation
        resource :confirm_organisation, only: %i[edit update], as: :framework_request_confirm_organisation
        resource :name, only: %i[edit update], as: :framework_request_name
        resource :email, only: %i[edit update], as: :framework_request_email
        resource :bill_uploads, only: %i[edit update], as: :framework_request_bill_uploads
        resource :message, only: %i[edit update], as: :framework_request_message
        resource :procurement_amount, only: %i[edit update], as: :framework_request_procurement_amount
        resource :special_requirements, only: %i[edit update], as: :framework_request_special_requirements
      end
    end
  end
  resources :framework_request_submissions, only: %i[update show], path: "procurement-support-submissions"

  #
  # Situational Content ---------------------------------------------------------
  #

  get "/pages/:page", to: "static_pages#show"

  #
  # General Support Requests ---------------------------------------------------
  #
  resources :support_requests, except: %i[destroy], path: "support-requests"
  resources :support_request_submissions, only: %i[update show], path: "support-request-submissions"
  post "/submit", to: "api/support/requests#create", as: :submit_request

  resources :journeys, only: %i[new show create destroy edit update] do
    resource :specification, only: %i[create show] do
      get :download, to: "specifications#new"
    end
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
    resources :document_downloads, only: %i[show]
    resources :agents, only: %i[create]
    resources :email_read_status, only: %i[update], param: :email_id
    resources :organisations, only: %i[index]
    resources :establishments, only: %i[index]
    resources :establishment_groups, only: %i[index]
    resources :frameworks, only: %i[index]
    resources :towers, only: [:show]
    resources :cases, only: %i[index show edit update new create] do
      resources :interactions, only: %i[new create show]
      scope module: :cases do
        collection do
          resource :preview, only: %i[new create], as: :create_case_preview
          resources :searches, only: %i[new index], as: :case_search, path: "find-a-case"
        end
        resources :attachments, only: %i[index]
        resources :files, only: %i[index]
        resource :merge_emails, only: %i[new create show], path: "merge-emails"
        resource :organisation, only: %i[edit update]
        resource :contact_details, only: %i[edit update]
        resource :request_details, only: %i[edit update]
        resource :closures, only: %i[edit update]
        resource :savings, only: %i[edit update]
        resource :procurement_details, only: %i[edit update]
        resources :documents, only: %i[show]
        resource :resolution, only: %i[new create]
        resources :assignments, only: %i[new create index]
        resource :opening, only: %i[create]
        resource :closure, only: %i[new create]
        resource :on_hold, only: %i[create]
        resource :summary, only: %i[edit update]
        resource :summary_submission, only: %i[edit update]
        resources :contracts, only: %i[edit update]
        resource :email, only: %i[create] do
          scope module: :emails do
            resources :content, only: %i[show], param: :template
            resources :templates, only: %i[index], param: :template
          end
        end
        resources :message_threads, only: %i[index show new] do
          scope do
            collection do
              get "templated_messages"
              get "logged_contacts"
            end
          end
        end
        resources :messages, only: %i[create] do
          scope module: :messages do
            resources :replies, only: %i[create]
          end
        end
      end
    end

    resources :notifications, only: :index do
      scope module: :notifications do
        resource :read, only: %i[create destroy]

        collection do
          resource :mark_all_read, only: %i[create], as: :notifications_mark_all_read
        end
      end
    end

    resources :messages do
      resource :save_attachments, only: %i[new create]
    end

    resource :case_statistics, only: :show do
      scope module: :case_statistics do
        resources :towers, only: :show
      end
    end

    namespace :management do
      get "/", to: "base#index"
      resources :agents, only: %i[index update]
      resources :categories, only: %i[index update]
      resource :category_detection, only: %i[new create]
      resources :all_cases_surveys, only: %i[index create]
    end
  end

  if Rails.env.development?
    require "sidekiq/web"
    mount Sidekiq::Web, at: "/sidekiq"
  end

  flipper_app = Flipper::UI.app do |builder|
    if Rails.env.production?
      builder.use Rack::Auth::Basic do |username, password|
        username == ENV["FLIPPER_USERNAME"] && password == ENV["FLIPPER_PASSWORD"]
      end
    end
  end
  mount flipper_app, at: "/flipper"

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

  namespace :exit_survey do
    resources :start, only: %i[show]
    resources :satisfaction, only: %i[edit update]
    resources :satisfaction_reason, only: %i[edit update]
    resources :saved_time, only: %i[edit update]
    resources :better_quality, only: %i[edit update]
    resources :future_support, only: %i[edit update]
    resources :hear_about_service, only: %i[edit update]
    resources :opt_in, only: %i[edit update]
    resources :opt_in_detail, only: %i[edit update]
    resources :thank_you, only: %i[show]
  end

  namespace :all_cases_survey do
    resources :start, only: %i[show]
    resources :satisfaction, only: %i[edit update]
    resources :satisfaction_reason, only: %i[edit update]
    resources :outcome_achieved, only: %i[edit update]
    resources :about_outcomes, only: %i[edit update]
    resources :improvements, only: %i[edit update]
    resources :accessibility_research, only: %i[edit update]
    resources :thank_you, only: %i[show]
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
