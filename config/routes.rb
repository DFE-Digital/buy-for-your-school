# frozen_string_literal: true

Rails.application.routes.draw do
  #
  # Common ---------------------------------------------------------------------
  #
  get "health_check" => "application#health_check"

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

  # Contentful
  post "/api/contentful/auth" => "api/contentful/base#auth"
  post "/api/contentful/entry_updated" => "api/contentful/entries#changed"
  post "/api/contentful/category" => "api/contentful/categories#changed"

  # 681 - guard against use of back button after form validation errors
  get "/journeys/:journey/steps/:step/answers", to: redirect("/journeys/%{journey}/steps/%{step}")

  resources :design, only: %i[index show]
  resources :categories, only: %i[index]
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
  namespace :support do
    get "admin", to: "admin#show"
  end
end
