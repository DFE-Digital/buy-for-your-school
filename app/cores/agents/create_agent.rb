module Agents
  class CreateAgent
    include Wisper::Publisher

    def call(support_agent_details:)
      # Reuse any existing agent for the e-mail address supplied as login only uses the first one it finds; newer ones are ignored
      existing_agent = Support::Agent.find_by(email: support_agent_details.slice(:email, :first_name, :last_name)[:email])
      if existing_agent
        existing_agent
      else
        agent = Support::Agent.create!(support_agent_details.slice(:email, :first_name, :last_name))
        broadcast(:agent_created, agent.id)
        agent
      end
    end
  end
end
