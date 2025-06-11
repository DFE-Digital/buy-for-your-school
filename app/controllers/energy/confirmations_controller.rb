module Energy
  class ConfirmationsController < Energy::ApplicationController
    def show
      @case_ref_no = onboarding_case.support_case.ref
    end
  end
end
