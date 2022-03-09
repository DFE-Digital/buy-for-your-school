module Support
  class Cases::ApplicationController < ApplicationController
    before_action :current_case

  private

    def state_change_body(to)
      "From #{current_state} to #{to} by #{current_agent.full_name} on #{now}"
    end

    def current_state
      I18n.t("support.case.label.state.state_#{current_case.state}").downcase
    end

    def now
      Time.zone.now.to_formatted_s(:short)
    end

    # @return [Case, nil]
    def current_case
      @current_case ||= Case.find_by(id: params[:case_id])
    end

    # @return [AgentPresenter, nil]
    def current_agent
      AgentPresenter.new(super) if super
    end
  end
end
