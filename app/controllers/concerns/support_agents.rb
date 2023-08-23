module SupportAgents
  extend ActiveSupport::Concern

  included do
    rescue_from Pundit::NotAuthorizedError, with: :on_not_authorized_error

    before_action :redirect_non_internal_users!
    before_action :authorize_agent!
    before_action :set_current_agent

    helper_method :current_agent
  end

  def set_current_agent
    Current.agent = @current_agent
  end

  def current_agent
    @current_agent ||= Support::Agent.find_or_create_by_user(current_user)
  end

  def pundit_user = current_agent

  def redirect_non_internal_users!
    redirect_to root_path unless current_user.internal?
  end

  def authorize_agent!
    Array(authorize_agent_scope).flatten.each do |scope|
      authorize :cms_portal, scope
    end
  end

  def on_not_authorized_error = redirect_to on_not_authorized_error_redirect_path

  def on_not_authorized_error_redirect_path = current_agent.roles.any? ? cms_not_authorized_path : cms_no_roles_assigned_path

  def tracking_base_properties = super.merge(agent_id: current_agent.id)
end
