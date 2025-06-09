module Support
  class Cases::ApplicationController < ::Support::ApplicationController
    before_action :current_case

  private

    def change_case_state(args)
      ChangeCaseState.new(
        kase: current_case,
        agent: current_agent,
        **args,
      ).call
    end

    # @return [Case, nil]
    def current_case
      @current_case ||= Case.find_by(id: params[:case_id])
    end

    # @return [AgentPresenter, nil]
    def current_agent
      AgentPresenter.new(super) if super
    end

    def is_user_cec_agent?
      (current_agent.roles & %w[cec cec_admin]).any?
    end

    def agent_portal_namespace
      (current_agent.roles & %w[cec cec_admin]).any? ? "cec" : "support"
    end

    def authorize_agent_scope = :access_individual_cases?
  end
end
