module Support
  class Management::AgentsController < ::Support::Management::BaseController
    include ManageSupportAgents
    before_action(only: %i[new edit create update]) { @back_url = support_management_agents_path }
    before_action(only: [:index]) { @back_url = support_management_path }

  private

    def authorize_agent_scope = [super, :manage_agents?]
  end
end
