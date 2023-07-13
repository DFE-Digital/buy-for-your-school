module Support
  class Management::AgentsController < ::Support::Management::BaseController
    def index
      @agents = Support::Agent.by_first_name.map { |agent| Support::AgentPresenter.new(agent) }
    end

    def new
      @agent = Support::Agent.new
      @form = Support::Management::AgentForm.from_agent(@agent)
      @back_url = support_management_agents_path
    end

    def edit
      @agent = Support::Agent.find(params[:id])
      @form = Support::Management::AgentForm.from_agent(@agent)
      @back_url = support_management_agents_path
    end

    def create
      @form = Support::Management::AgentForm.new(agent_form_params)
      @back_url = support_management_agents_path

      if @form.valid?
        create_agent = Agents::CreateAgent.new
        @agent = create_agent.call(support_agent_details: agent_form_params.to_h.symbolize_keys)

        assign_roles = Agents::AssignRoles.new
        assign_roles.call(
          support_agent_id: @agent.id,
          new_roles: agent_form_params[:roles],
          cms_policy: policy(:cms_portal),
        )

        redirect_to support_management_agents_path
      else
        render :new
      end
    end

    def update
      @agent = Support::Agent.find(params[:id])
      @form = Support::Management::AgentForm.new(agent_form_params)
      @back_url = support_management_agents_path

      if @form.valid?
        update_agent = Agents::UpdateAgent.new
        update_agent.call(
          support_agent_id: @agent.id,
          support_agent_details: agent_form_params.to_h.symbolize_keys,
        )

        assign_roles = Agents::AssignRoles.new
        assign_roles.call(
          support_agent_id: @agent.id,
          new_roles: agent_form_params[:roles],
          cms_policy: policy(:cms_portal),
        )

        redirect_to support_management_agents_path
      else
        render :edit
      end
    end

  private

    def authorize_agent_scope = [super, :manage_agents?]

    def agent_form_params
      params.require(:agent).permit(:email, :first_name, :last_name, roles: []).tap do |p|
        p[:roles].reject!(&:blank?)
      end
    end
  end
end
