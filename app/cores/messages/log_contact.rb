module Messages
  class LogContact
    include Wisper::Publisher

    def call(support_case_id:, agent_id:, event_type:, body:)
      contact = Support::Interaction.new(
        case_id: support_case_id,
        agent_id:,
        event_type:,
        body:,
      )

      broadcast(:contact_to_school_made, { support_case_id:, contact_type: "logged #{contact.event_type.humanize(capitalize: false)}" }) if contact.save!
    end
  end
end
