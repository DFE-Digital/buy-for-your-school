module Support
  class ApplicationController < ::ApplicationController
    before_action :authenticate_agent!

  protected

    helper_method :current_agent

    # @return [AgentPresenter, nil]
    def current_agent
      AgentPresenter.new(Agent.find_by(dsi_uid: session[:dfe_sign_in_uid]))
    end

    # @return [nil]
    def authenticate_agent!
      return if current_agent.respond_to?(:id)

      redirect_to support_root_path, notice: "You are not a recognised case worker"
    end

    def record_action(case_id:, action:, data: {})
      Support::RecordAction.new(
        case_id: case_id,
        action: action,
        data: data,
      ).call
    end
  end
end
