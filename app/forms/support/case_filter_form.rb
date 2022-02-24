# frozen_string_literal: true

module Support
  class CaseFilterForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    # @!attribute [r] state
    #   @return [String]
    option :state, optional: true

    # @!attribute [r] category_id
    #   @return [String]
    option :category, optional: true

    # @!attribute [r] agent_id
    #   @return [String]
    option :agent, optional: true

    def agents
      @agents ||= Support::Agent.all.map { |a| AgentPresenter.new(a) }
    end
  end
end