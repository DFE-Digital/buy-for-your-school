# frozen_string_literal: true

Rails.application.routes.draw do
  get "health_check" => "application#health_check"
  root to: "pages#show", id: "specifying_start_page"

  get "planning" => "pages#show", "id" => "planning_start_page"
  post "/api/contentful/auth" => "api/contentful/base#auth"
  post "/api/contentful/entry_updated" => "api/contentful/entries#changed"
  post "/api/contentful/category" => "api/contentful/categories#changed"

  # DfE Sign In
  get "/auth/dfe/callback", to: "sessions#create"
  get "/auth/dfe/signout", to: "sessions#destroy"
  get "/auth/failure", to: "sessions#failure"
  post "/auth/developer/callback" => "sessions#bypass_callback" if Rails.env.development?

  resources :journey_maps, only: %i[index show]
  resources :categories, only: %i[index]
  resources :journeys, only: %i[show create] do
    resource :specification, only: [:show]
    resources :steps, only: %i[new show edit] do
      resources :answers, only: %i[create update]
    end
    resources :tasks, only: [:show]
  end

  # 681 - guard against use of back button after form validation errors
  get "/journeys/:journey/steps/:step/answers", to: redirect("/journeys/%{journey}/steps/%{step}")

  namespace :preview do
    resources :entries, only: [:show]
  end

  get "dashboard", to: "dashboard#show"

  # Errors
  get "/404", to: "errors#not_found"
  get "/422", to: "errors#unacceptable"
  get "/500", to: "errors#internal_server_error"
end
