# frozen_string_literal: true

Rails.application.routes.draw do
  get "health_check" => "application#health_check"
  root to: "high_voltage/pages#show", id: "specifying_start_page"

  get "planning" => "high_voltage/pages#show", "id" => "planning_start_page"

  # DfE Sign In
  resource :sessions,
    only: %i[create new],
    as: :dfe,
    path: "/dfe/sessions",
    controller: "sessions"

  get "/auth/dfe/callback", to: "sessions#create"
  get "/auth/dfe/signout", to: "sessions#destroy"
  get "/auth/failure", to: redirect("/dfe/sessions/new", status: 303)

  resource :journey_map, only: [:new]
  resources :journeys, only: [:new, :show] do
    resource :specification, only: [:show]
    resources :steps, only: [:new, :show, :edit] do
      resources :answers, only: [:create, :update]
    end
  end

  namespace :preview do
    resources :entries, only: [:show]
  end
end
