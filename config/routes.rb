# frozen_string_literal: true

Rails.application.routes.draw do
  get "health_check" => "application#health_check"
  root to: "pages#show", id: "specifying_start_page"

  get "planning" => "pages#show", "id" => "planning_start_page"
  post "/api/contentful/entry_updated" => "api/contentful/entries#changed"

  # DfE Sign In
  get "/auth/dfe/callback", to: "sessions#create"
  get "/auth/dfe/signout", to: "sessions#destroy"
  get "/auth/failure", to: "sessions#failure"
  post "/auth/developer/callback" => "sessions#bypass_callback" if Rails.env.development?

  resources :journey_maps, only: %i[index show]
  resources :categories, only: %i[index]
  resources :journeys, only: %i[show] do
    resource :specification, only: [:show]
    resources :steps, only: %i[new show edit] do
      resources :answers, only: %i[create update]
    end
    resources :tasks, only: [:show]
  end

  post "categories/new_spec", to: "categories#new_spec"
  post "categories/new_journey_mapper", to: "categories#new_journey_mapper"
  get "journeys/new/:category_id", to: "journeys#new", as: :new_journey
  get "journeys_maps/new/:category_id", to: "journey_maps#new", as: :new_journey_map

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
