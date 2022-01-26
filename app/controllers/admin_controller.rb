# frozen_string_literal: true

class AdminController < ApplicationController
  before_action :user_analyst, only: :show
  before_action :set_view_fields, only: :show

  def show
    respond_to do |format|
      format.html do
        Rollbar.info("User role has been granted access.", role: "analyst", path: request.path)
      end
      format.csv do
        Rollbar.info("User activity data downloaded.")
        csv = ActivityLogItem.to_csv
        send_data csv, filename: "user_activity_data.csv", type: "text/csv"
      end
      format.json do
        Rollbar.info("User activity data downloaded.")
        json = JSON.pretty_generate(ActivityLogItem.all.as_json)
        send_data json, filename: "user_activity_data.json", type: "application/json"
      end
    end
  end

private

  def user_analyst
    render "errors/missing_role" unless current_user.analyst?
  end

  def set_view_fields
    @no_of_users = User.count
    @no_of_specs = Journey.count
    @last_registration_date = UserPresenter.new(User.order(created_at: :desc).first).created_at
  end
end
