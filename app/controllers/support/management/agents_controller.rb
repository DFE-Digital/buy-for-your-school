module Support
  class Management::AgentsController < ::Support::Management::BaseController
    def index
      @agents = Support::Agent.by_first_name.map { |agent| Support::AgentPresenter.new(agent) }
    end

    def edit
      @agent = Support::Agent.find(params[:id])
      @back_url = support_management_agents_path
    end

    def update
      Agents::AssignRoles.new.call(
        support_agent_id: params[:id],
        new_roles: agent_form_params[:roles],
        cms_policy: policy(:cms_portal),
      )

      redirect_to support_management_agents_path
    end

  private

    def agent_form_params
      params.require(:agent).permit(roles: []).tap do |p|
        p[:roles].reject!(&:blank?)
      end
    end
  end
end
