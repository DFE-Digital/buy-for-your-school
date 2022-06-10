module Support
  #
  # Send an exit survey email to a user
  #
  class SendExitSurveyJob < ApplicationJob
    queue_as :support

    def perform(case_ref)
      kase = Case.find_by_ref(case_ref)
      recipient = OpenStruct.new(
        email: kase.email,
        first_name: kase.first_name,
        last_name: kase.last_name,
        full_name: "#{kase.first_name} #{kase.last_name}",
      )

      ::Emails::ExitSurvey.new(
        recipient: recipient,
        reference: case_ref,
      ).call

      update_case(kase)
    end

  private

    def update_case(kase)
      kase.exit_survey_sent = true
      kase.interactions.note.build(body: I18n.t("support.interaction.message.exit_survey_sent"))
      kase.save!
    end
  end
end
