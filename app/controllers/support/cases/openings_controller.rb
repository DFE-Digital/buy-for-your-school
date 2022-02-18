module Support
  class Cases::OpeningsController < Cases::ApplicationController
    def create
      current_case.interactions.note.build(
        body: "Case reopened",
        agent_id: current_agent.id,
      )
      current_case.open!

      redirect_to support_case_path(current_case, anchor: "case-history"),
                  notice: I18n.t("support.case_opening.flash.reopened")
    end
  end
end
