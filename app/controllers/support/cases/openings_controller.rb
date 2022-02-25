module Support
  class Cases::OpeningsController < Cases::ApplicationController
    def create
      if current_case.may_open?
        current_case.interactions.state_change.build(
          body: "Case set to open",
          agent_id: current_agent.id,
        )

        current_case.open!

        redirect_to support_case_path(current_case, anchor: "case-history"),
                    notice: I18n.t("support.case_opening.flash.reopened")
      else
        redirect_to support_case_path(current_case),
                    notice: I18n.t("support.case_opening.flash.error")
      end
    end
  end
end
