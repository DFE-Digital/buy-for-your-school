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

    def back_link_param
      return if params[:back_to].blank?

      Base64.decode64(params[:back_to])
    end
  end
end
