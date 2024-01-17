module ManageSupportAgents
  extend ActiveSupport::Concern

  included do
    helper_method(
      :portal_edit_management_agent_path,
      :portal_new_management_agent_path,
      :portal_management_agents_path,
      :portal_management_path,
    )
  end

  def index
    @enabled_agents = Support::Agent.enabled.by_first_name.map { |agent| Support::AgentPresenter.new(agent) }
    @disabled_agents = Support::Agent.disabled.by_first_name.map { |agent| Support::AgentPresenter.new(agent) }
  end

  def new
    @agent = Support::Agent.new
    @form = Support::Management::AgentForm.from_agent(@agent)
  end

  def edit
    @agent = Support::Agent.find(params[:id])
    @form = Support::Management::AgentForm.from_agent(@agent)
  end

  def create
    @form = Support::Management::AgentForm.new(agent_form_params)

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

  def portal_edit_management_agent_path(agent) = send("edit_#{portal_namespace}_management_agent_path", agent)
  def portal_new_management_agent_path = send("new_#{portal_namespace}_management_agent_path")
  def portal_management_agents_path = send("#{portal_namespace}_management_agents_path")
  def portal_management_path = send("#{portal_namespace}_management_path")

  def agent_form_params
    params.require(:agent).permit(:email, :first_name, :last_name, roles: []).tap do |p|
      p[:roles].reject!(&:blank?)
    end
  end
end
