module Support
  class Cases::OpeningsController < Cases::ApplicationController
    before_action :set_back_url, only: %i[new create]

    def new
      @current_case = CasePresenter.new(@current_case)
    end

    def create
      if current_case.may_open?
        is_current_state_closed = @current_case.closed?

        state_data = @current_case.previous_state_of("change_state")
        state_data["old_state"] == "initial" && state_data["new_state"] == "closed" ? change_case_state(to: :initial) : change_case_state(to: :open)

        @current_case.notify_agent_of_case_reopened if @current_case.agent.present? && is_current_state_closed

        redirect_to support_case_path(current_case, anchor: "case-history"),
                    notice: I18n.t("support.case_opening.flash.reopened")
      else
        redirect_to support_case_path(current_case),
                    notice: I18n.t("support.case_opening.flash.error")
      end
    end

  private

    def set_back_url
      @back_url = support_case_path(@current_case, anchor: "case-details")
    end
  end
end
