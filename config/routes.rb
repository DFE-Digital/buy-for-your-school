# frozen_string_literal: true

Rails.application.routes.draw do
  get "health_check" => "application#health_check"
  root to: "high_voltage/pages#show", id: "planning_start_page"

  resources :journeys, only: [:new, :show] do
    resources :steps, only: [:new, :show] do
      resources :answers, only: [:create]
    end
  end

  namespace :preview do
    resources :entries, only: [:show]
  end
end
