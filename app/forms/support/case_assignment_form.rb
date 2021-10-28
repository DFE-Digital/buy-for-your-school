module Support
  class CaseAssignmentForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    option :agent_id, Types::Params::String, optional: true

    def new_agent
      @new_agent ||= AgentPresenter.new(Agent.find(agent_id))
    end
  end
end
