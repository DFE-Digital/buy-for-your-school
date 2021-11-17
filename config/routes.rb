# frozen_string_literal: true

Rails.application.routes.draw do
  #
  # Common ---------------------------------------------------------------------
  #
  get "health_check" => "application#health_check"
  get "privacy" => "pages#privacy_notice", "id" => "privacy"
  get "accessibility" => "pages#accessibility", "id" => "accessibility"
  get "terms-and-conditions" => "pages#terms_and_conditions", "id" => "terms_and_conditions"
  get "next-steps-catering" => "pages#next_steps_catering", "id" => "next_steps_catering"
  get "next-steps-mfd" => "pages#next_steps_mfd", "id" => "next_steps_mfd"

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
  root to: "pages#show", id: "specifying_start_page"

  get "planning" => "pages#show", "id" => "planning_start_page"
  get "dashboard", to: "dashboard#show"
  get "profile", to: "profile#show"

  # Contentful
  namespace :api do
    namespace :contentful do
      post "auth" => "base#auth"
      post "entry_updated" => "entries#changed"
      post "category" => "categories#changed"
      post "page" => "pages#create"
      delete "page" => "pages#destroy"
    end
  end

  # NB: guard against use of back button after form validation errors
  get "/journeys/:journey/steps/:step/answers", to: redirect("/journeys/%{journey}/steps/%{step}")

  resources :design, only: %i[index show]
  resources :categories, only: %i[index]

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
    resources :agents, only: %i[create]
    resources :cases, only: %i[index show edit update] do
      resources :interactions, only: %i[new create]
      scope module: :cases do
        resource :categorisation, only: %i[edit update]
        resources :documents, only: %i[show]
        resource :resolution, only: %i[new create]
        resource :assignment, only: %i[new create]
        resource :email, only: %i[create] do
          scope module: :emails do
            resource :type, only: %i[new create]
            resources :content, only: %i[edit show update], param: :template
            resources :templates, only: %i[index], param: :template
          end
        end
      end
    end
    resources :schools, only: %i[show index]
  end
end
