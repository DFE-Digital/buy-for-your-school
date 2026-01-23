class Fabs::ApplicationController < ApplicationController
  # Temporary base controller for FABS/GHBS public-facing routes.
  # Controllers for the merged school-user frontend can inherit from this
  # to be protected by the feature flag during rollout.
  #
  # NOTE: This Fabs namespace is temporary and will be removed once the
  # unified GHBS application is fully live.

  skip_before_action :authenticate_user!
  before_action :check_fabs_flag

private

  def check_fabs_flag
    # When the unified GHBS frontend feature flag is disabled, we keep the
    # existing behaviour (serving the current external GHBS/FABS site).
    return if Flipper.enabled?(:ghbs_public_frontend)

    redirect_to ENV.fetch("GHBS_HOMEPAGE_URL"), status: :temporary_redirect
  end
end

