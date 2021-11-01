# frozen_string_literal: true

class ProfileController < ApplicationController
  breadcrumb "Dashboard", :dashboard_path

  # The current user may no longer be a member of a supported school, if:
  #   1. an internal team member or ProcOps caseworker
  #   2. an SBP has their school affiliation revoked
  #
  # NB: Hide the support request link from unsupported users
  # TODO: advise unsupported users to remedy their school affiliation
  def show
    breadcrumb "Profile", profile_path, match: :exact
    @current_user = UserPresenter.new(current_user)
  end
end
