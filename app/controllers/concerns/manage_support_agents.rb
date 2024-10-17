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
      @agent = Support::Agent.find_or_create_by!(agent_form_params.except(:roles, :first_name, :last_name))
      @agent.update(first_name: agent_form_params[:first_name], last_name: agent_form_params[:last_name])
      @agent.assign_roles(new_roles: agent_form_params[:roles], using_policy: policy(:cms_portal))

      redirect_to support_management_agents_path
    else
      render :new
    end
  end

  def update
    @agent = Support::Agent.find(params[:id])
    @form = Support::Management::AgentForm.new(agent_form_params)

    if @form.valid?
      @agent.update!(agent_form_params.except(:roles))
      @agent.assign_roles(new_roles: agent_form_params[:roles], using_policy: policy(:cms_portal))

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
