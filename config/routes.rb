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

  resource :journey_map, only: [:new]
  resources :journeys, only: [:index, :new, :show] do
    resource :specification, only: [:show]
    resources :steps, only: [:new, :show, :edit] do
      resources :answers, only: [:create, :update]
    end
    resources :tasks, only: [:show]
  end

  namespace :preview do
    resources :entries, only: [:show]
  end

  get "dashboard", to: "dashboard#show"
end
