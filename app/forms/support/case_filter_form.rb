# frozen_string_literal: true

# :nocov:
module Support
  class CaseFilterForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    # @!attribute [r] search_term
    #   @return [String]
    option :search_term, Types::Params::String, optional: true

    # @!attribute [r] page
    #   @return [String]
    option :page, optional: true

    # @!attribute [r] state
    #   @return [String]
    option :state, optional: true

    # @!attribute [r] category_id
    #   @return [String]
    option :category_id, optional: true

    # @!attribute [r] agent_id
    #   @return [String]
    option :agent_id, optional: true

    def agents
      @agents ||= Support::Agent.all.map { |a| AgentPresenter.new(a) }
    end
  end
end
# :nocov:
