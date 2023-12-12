module Support
  #
  # Send an exit survey email to a user
  #
  class SendExitSurveyJob < ApplicationJob
    queue_as :support

    def self.start(case_ref)
      if exit_survey_delay.present?
        set(wait: exit_survey_delay.to_i.minutes).perform_later(case_ref)
      else
        perform_now(case_ref)
      end
    end

    def self.exit_survey_delay
      ENV["EXIT_SURVEY_EMAIL_DELAY"]
    end

    def perform(case_ref)
      kase = Case.find_by_ref(case_ref)
      return if kase.exit_survey_sent? || !kase.resolved?

      if Flipper.enabled?(:customer_satisfaction_survey)
        survey = CustomerSatisfactionSurveyResponse.create!(
          service: :supported_journey,
          source: :exit_survey,
          status: :sent_out,
          survey_sent_at: Time.zone.now,
        )

        ::Emails::CustomerSatisfactionSurvey.new(
          recipient: kase,
          reference: case_ref,
          survey_id: survey.id,
          caseworker_name: kase.agent_for_satisfaction_survey,
        ).call
      else
        survey = ExitSurveyResponse.create!(
          case: kase,
          status: :sent_out,
          survey_sent_at: Time.zone.now,
        )

        ::Emails::ExitSurvey.new(
          recipient: kase,
          reference: case_ref,
          survey_id: survey.id,
        ).call
      end

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
