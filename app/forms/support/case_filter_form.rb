# frozen_string_literal: true

module Support
  class CaseFilterForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    # @!attribute [r] state
    # @return [String]
    option :state, optional: true

    # @!attribute [r] category
    # @return [String]
    option :category, optional: true

    # @!attribute [r] agent
    # @return [String]
    option :agent, optional: true

    def agents
      @agents ||= Support::Agent.all.map { |a| AgentPresenter.new(a) }
    end

    def categories
      @categories ||= Case.joins(:category).select("support_categories.id, support_categories.title").order("support_categories.title").uniq
    end
  end
end
