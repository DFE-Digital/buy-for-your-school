module Energy
  class ConfirmationsController < Energy::ApplicationController
    before_action :organisation_details
    skip_before_action :check_if_submitted

    def show
      @case_ref_no = onboarding_case.support_case.ref
      @trust_code = @organisation_detail.trust_code
    end
  end
end
