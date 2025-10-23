module Engagement
  class Management::AgentsController < ::Engagement::Management::BaseController
    def self.controller_path = "support/management/agents"

    before_action only: %i[new edit create update] do
      @back_url = engagement_management_agents_path
    end

    before_action only: [:index] do
      @back_url = engagement_management_path
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
      @agent = Support::Management::AgentForm.find(params[:id])
    end

    def create
      @agent = Support::Management::AgentForm
        .find_or_initialize_by(email: agent_form_params[:email].downcase)
      @agent.assign_attributes(agent_form_params)

      if @agent.valid?
        @agent.save!
        @agent.update!(archived: false)
        redirect_to engagement_management_agents_path
      else
        render :new
      end
    end

    def update
      @agent = Support::Management::AgentForm.find(params[:id])

      if @agent.valid?
        @agent.update!(agent_form_params)
        redirect_to engagement_management_agents_path
      else
        render :edit
      end
    end

    def destroy
      @agent = Support::Management::AgentForm.find(params[:id])
      return unless params[:confirm]

      destroy_params = { policy: policy(:cms_portal) }
      destroy_params[:roles] = []
      destroy_params[:archived] = true

      @agent.update!(destroy_params)

      redirect_to engagement_management_agents_path,
                  notice: I18n.t("support.management.agents.destroyed", name: @agent.full_name, email: @agent.email)
    end

  private

    helper_method def redirect_path
      engagement_management_agents_path
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

    helper_method def portal_management_agent_path(agent, additional_params = {})
      send("#{portal_namespace}_management_agent_path", agent, additional_params)
    end

    helper_method def portal_management_path
      send("#{portal_namespace}_management_path")
    end

    def agent_form_params
      params.require(:agent).permit(:email, :first_name, :last_name, roles: [])
            .merge(policy: policy(:cms_portal))
            .tap { |p| p[:email] = p[:email].strip if p[:email].present? }
    end

    def authorize_agent_scope = [super, :manage_agents?]
  end
end
