module Support
  class Management::AgentsController < ::Support::Management::BaseController
    before_action only: %i[new edit create update] do
      @back_url = is_user_cec_agent? ? cec_management_agents_path : support_management_agents_path
    end

    before_action only: [:index] do
      @back_url = support_management_path
    end

    def index
      @enabled_agents = Support::Agent.enabled.by_first_name
        .map { |agent| Support::AgentPresenter.new(agent) }
      @disabled_agents = Support::Agent.disabled.by_first_name
        .map { |agent| Support::AgentPresenter.new(agent) }
    end

    def new
      @agent = Support::Management::AgentForm.new
    end

    def edit
      agent = Support::Agent.find(params[:id])
      @agent = Support::Management::AgentForm.new(**agent.to_h)
    end

    def create
      @agent = Support::Management::AgentForm
        .find_or_initialize_by(email: agent_form_params[:email].downcase)
      @agent.assign_attributes(agent_form_params.merge(is_user_cec_agent: is_user_cec_agent?))

      if @agent.valid?
        @agent.save!
        redirect_to redirect_path
      else
        render :new
      end
    end

    def update
      @agent = Support::Management::AgentForm.find(params[:id])
      @agent.assign_attributes(agent_form_params.merge(is_user_cec_agent: is_user_cec_agent?))
      if @agent.valid?
        @agent.update!(agent_form_params)
        redirect_to redirect_path
      else
        render :edit
      end
    end

  private

    def redirect_path
      is_user_cec_agent? ? cec_management_agents_path : support_management_agents_path
    end

    helper_method def is_user_cec_agent?
      (current_agent.roles & %w[cec cec_admin]).any?
    end

    helper_method def portal_edit_management_agent_path(agent)
      send("edit_#{portal_namespace}_management_agent_path", agent)
    end

    helper_method def portal_new_management_agent_path
      send("new_#{portal_namespace}_management_agent_path")
    end

    helper_method def portal_management_agents_path
      send("#{portal_namespace}_management_agents_path")
    end

    helper_method def portal_management_agent_path(agent)
      send("#{portal_namespace}_management_agent_path", agent)
    end

    helper_method def portal_management_path
      send("#{portal_namespace}_management_path")
    end

    def agent_form_params
      params.require(:agent).permit(:email, :first_name, :last_name, roles: [])
        .merge(policy: policy(:cms_portal))
    end

    def authorize_agent_scope = [super, :manage_agents?]
  end
end
