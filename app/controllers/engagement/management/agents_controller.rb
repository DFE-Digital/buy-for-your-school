module Engagement
  class Management::AgentsController < ::Engagement::Management::BaseController
    include ManageSupportAgents
    def self.controller_path = "support/management/agents"
    before_action(only: %i[new edit create update]) { @back_url = engagement_management_agents_path }
    before_action(only: [:index]) { @back_url = engagement_management_path }

  private

    def authorize_agent_scope = [super, :manage_agents?]
  end
end
