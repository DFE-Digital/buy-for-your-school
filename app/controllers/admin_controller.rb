# frozen_string_literal: true

class AdminController < ApplicationController
  include SupportAgents

  before_action :set_view_fields, only: :show

  def show
    Rollbar.info("User role has been granted access.", role: "analyst", path: request.path)
  end

  def download_user_activity
    respond_to do |format|
      Rollbar.info("User activity data downloaded.")
      data = download_data(params[:format], ActivityLogItem)
      format.csv do
        send_data data, filename: "user_activity_data.csv", type: "text/csv"
      end
      format.json do
        send_data data, filename: "user_activity_data.json", type: "application/json"
      end
    end
  end

  def download_users
    respond_to do |format|
      Rollbar.info("User data downloaded.")
      data = download_data(params[:format], User)
      format.json do
        send_data data, filename: "user_data.json", type: "application/json"
      end
    end
  end

private

  def authorize_agent_scope = :access_legacy_admin?

  def set_view_fields
    @no_of_users = User.count
    @no_of_specs = Journey.count
    @last_registration_date = UserPresenter.new(User.order(created_at: :desc).first).created_at
  end

  def download_data(format, model)
    case format
    when "csv"
      model.to_csv
    when "json"
      JSON.pretty_generate(model.all.as_json)
    end
  end
end
