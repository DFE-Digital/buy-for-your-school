module Agents
  class UpdateAgent
    include Wisper::Publisher

    def call(support_agent_id:, support_agent_details:)
      agent = Support::Agent.find(support_agent_id)
      agent.update!(support_agent_details.slice(:email, :first_name, :last_name))

      broadcast(:agent_updated, agent.id)

      agent
    end
  end
end
