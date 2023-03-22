module CaseManagement
  class CreateInteraction
    include Wisper::Publisher

    def call(support_case_id:, agent_id:, event_type:, body:)
      interaction = Support::Interaction.new(
        case_id: support_case_id,
        agent_id:,
        event_type:,
        body:,
      )

      broadcast(:interaction_created, { interaction_id: interaction.id, support_case_id:, event_type: }) if interaction.save!
    end
  end
end
