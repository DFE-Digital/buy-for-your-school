module Support
  class Cases::OnHoldsController < Cases::ApplicationController
    def create
      if current_case.may_hold?
        change_case_state(to: :hold)
        redirect_to redirect_to_case_history,
                    notice: I18n.t("support.case_on_hold.flash.created")
      else
        redirect_to redirect_to_case,
                    notice: I18n.t("support.case_on_hold.flash.error")
      end
    end

  private

    def authorize_agent_scope = :access_individual_cases?

    def redirect_to_case_history
      is_user_cec_agent? ? cec_onboarding_case_path(current_case, anchor: "case-history") : support_case_path(current_case, anchor: "case-history")
    end

    def redirect_to_case
      is_user_cec_agent? ? cec_onboarding_case_path(current_case) : support_case_path(current_case)
    end
  end
end
