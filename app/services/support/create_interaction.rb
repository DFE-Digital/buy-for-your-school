# frozen_string_literal: true

module Support
  class CreateInteraction
    # @param case_id [uuid] the case to add interaction to
    # @param event_type [String] the type of interaction
    # @param agent_id [uuid] the id of agent creating the interaction
    # @param attrs [Hash] hash of attrs to create interaction from
    def initialize(case_id = nil, event_type = "note", agent_id = nil, attrs = {})
      @case_id = case_id
      @event_type = event_type
      @agent_id = agent_id
      @attrs = attrs
    end

    # @return Support::Interaction
    def call
      i = Interaction.new(
        case_id: @case_id,
        event_type: @event_type,
        agent_id: @agent_id,
        body: @attrs[:body],
      )
      i.additional_data = @attrs[:additional_data] if @attrs[:additional_data].present?
      i.save!
      i
    end
  end
end
