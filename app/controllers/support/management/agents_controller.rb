module Support
  class Management::AgentsController < ::Support::Management::BaseController
    def index
      @agents = with_presenters(Support::Agent.by_first_name.includes(:user))
    end

    def edit
      @agent = Support::Agent.find(params[:id])
      @back_url = support_management_agents_path
    end

    def update
      @agent = Support::Agent.find(params[:id])
      @agent.update!(agent_form_params)

      Rollbar.info(audit_message, admin_user_id: current_user.id, agent_id: @agent.id)

      redirect_to support_management_agents_path
    end

  private

    def with_presenters(agents)
      agents.map { |agent| Support::AgentPresenter.new(agent) }
    end

    def agent_form_params
      params.require(:agent).permit(:support_tower_id, roles: []).tap do |p|
        p[:roles].reject!(&:blank?)
      end
    end

    def audit_message
      base_message = "CMS Management: Agent details have been updated"
      return base_message unless @agent.user.previous_changes.include?(:admin)

      "#{base_message}. Admin flag #{@agent.user.admin ? 'enabled' : 'disabled'}."
    end
  end
end
