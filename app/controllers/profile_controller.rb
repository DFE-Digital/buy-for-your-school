# frozen_string_literal: true

class ProfileController < ApplicationController
  breadcrumb "Dashboard", :dashboard_path

  def show
    breadcrumb "Profile", profile_path, match: :exact

    # DSI: collate environment specific config like urls
    @edit_dsi_link = {
      production: "https://profile.signin.education.gov.uk/edit-details",
      staging: "https://pp-profile.signin.education.gov.uk/edit-details",
      test: "https://test-profile.signin.education.gov.uk/edit-details",
      development: "https://test-profile.signin.education.gov.uk/edit-details",
    }.fetch(Rails.env.to_sym)

    @current_user = UserPresenter.new(current_user)
  end
end
