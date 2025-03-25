require "dry-initializer"

module Support
  # Track support case activity
  #
  # @see Support::EvaluationJourneyTracking

  class EvaluationJourneyTracking
    def initialize(event_type, case_id, body, additional_data)
      @event_type = event_type
      @case_id = case_id
      @body = body
      @additional_data = additional_data
    end

    def call
      Support::Interaction.create!(
        body: @body,
        agent: Current.agent,
        case_id: @case_id,
        event_type: @event_type,
        additional_data: @additional_data,
        show_case_history: false,
      )
    end
  end
end
