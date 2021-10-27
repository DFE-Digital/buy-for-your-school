# frozen_string_literal: true

class ProfileController < ApplicationController
  breadcrumb "Dashboard", :dashboard_path

  def show
    breadcrumb "Profile", profile_path, match: :exact
    @current_user = UserPresenter.new(current_user)
  end
end
