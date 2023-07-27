# frozen_string_literal: true

class Specify::ProfileController < Specify::ApplicationController
  # The current user may no longer be a member of a supported school, if:
  #   1. an internal team member or ProcOps caseworker
  #   2. an SBP has their school affiliation revoked
  #
  # NB: Hide the support request link from unsupported users
  # TODO: advise unsupported users to remedy their school affiliation
  def show
    @current_user = UserPresenter.new(current_user)

    @support_journey = session.fetch(:support_journey, :digital).to_sym

    case @support_journey
    when :digital
      breadcrumb "Dashboard", :dashboard_path
      breadcrumb "Profile", profile_path, match: :exact
    when :faf
      # breadcrumb "Find a Framework", :framework_requests_path
    end
  end
end
