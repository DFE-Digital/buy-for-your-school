module Support
  class Cases::ClosingsController < Cases::ApplicationController

    def create
      current_case.interactions.note.build(
        body: "Case closed",
        agent_id: current_agent.id,
      )
      current_case.close!

      redirect_to support_case_path(current_case, anchor: "case-history"),
                  notice: I18n.t("support.case_closing.flash.created")
    end
  end
end
