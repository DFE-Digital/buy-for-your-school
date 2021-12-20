# frozen_string_literal: true

class AdminController < ApplicationController
  before_action :user_analyst, only: :show

  def show; end

private

  def user_analyst
    return render "errors/missing_role" unless current_user.analyst?

    Rollbar.info("User role has been granted access.", role: "analyst", path: request.path)
  end
end
