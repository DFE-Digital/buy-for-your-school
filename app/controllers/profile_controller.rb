# frozen_string_literal: true

class ProfileController < ApplicationController
  # The current user may no longer be a member of a supported school, if:
  #   1. an internal team member or ProcOps caseworker
  #   2. an SBP has their school affiliation revoked
  #
  # NB: Hide the support request link from unsupported users
  # TODO: advise unsupported users to remedy their school affiliation
  def show
    @current_user = UserPresenter.new(current_user)

    if session[:faf_referer]
      @support_journey = :faf
      @support_path = current_user.supported_schools.one? ? new_framework_request_path(step: 5) : new_framework_request_path(step: 4)

    else
      breadcrumb "Dashboard", :dashboard_path
      breadcrumb "Profile", profile_path, match: :exact
      @support_journey = :general
    end
  end
end
