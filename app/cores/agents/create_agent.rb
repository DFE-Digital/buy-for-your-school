module Agents
  class CreateAgent
    include Wisper::Publisher

    def call(support_agent_details:)
      agent = Support::Agent.create!(support_agent_details.slice(:email, :first_name, :last_name))

      broadcast(:agent_created, agent.id)

      agent
    end
  end
end
