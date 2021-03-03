# frozen_string_literal: true

Rails.application.routes.draw do
  get "health_check" => "application#health_check"
  root to: "high_voltage/pages#show", id: "specifying_start_page"

  resource :journey_map, only: [:new]
  resources :journeys, only: [:new, :show] do
    resources :steps, only: [:new, :show, :edit] do
      resources :answers, only: [:create, :update]
    end
  end

  namespace :preview do
    resources :entries, only: [:show]
  end
end
