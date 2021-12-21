# frozen_string_literal: true

class AdminController < ApplicationController
  before_action :user_analyst, only: :show
  before_action :set_view_fields, only: :show

  def show; end

private

  def user_analyst
    return render "errors/missing_role" unless current_user.analyst?

    Rollbar.info("User role has been granted access.", role: "analyst", path: request.path)
  end

  def set_view_fields
    @no_of_users = User.count
    @no_of_specs = Journey.count
    @last_registration_date = UserPresenter.new(User.order(created_at: :desc).first).created_at
  end
end
