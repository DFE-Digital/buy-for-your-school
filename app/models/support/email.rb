module Support
  class Email < ApplicationRecord
    belongs_to :case, class_name: "Support::Case", optional: true
    before_save :record_received_email, if: :case_id_changed?

  private

    def record_received_email
      return if case_id.nil?

      interaction_attrs = {
        body: body,
        additional_data:
        {
          email_id: id,
        },
      }
      CreateInteraction.new(self.case.id, "email_from_school", self.case.agent_id, interaction_attrs).call
    end
  end
end
