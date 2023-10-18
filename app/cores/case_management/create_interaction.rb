module CaseManagement
  class CreateInteraction
    include Wisper::Publisher

    def call(support_case_id:, agent_id:, event_type:, body:)
      support_case = Support::Case.find(support_case_id)
      interaction = Support::Interaction.new(
        case_id: support_case_id,
        agent_id:,
        event_type:,
        body:,
      )

      broadcast(:interaction_created, { interaction_id: interaction.id, support_case_id:, event_type: }) if interaction.save!

      support_case.hold_due_to_contact_with_school! if interaction.contact? && support_case.may_hold_due_to_contact_with_school?
    end
  end
end
