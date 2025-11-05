module Energy
  class ConfirmationsController < Energy::ApplicationController
    skip_before_action :check_if_submitted

    def show
      @case_ref_no = onboarding_case.support_case.ref
    end
  end
end
