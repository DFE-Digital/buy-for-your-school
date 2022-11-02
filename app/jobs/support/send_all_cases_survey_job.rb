module Support
  #
  # Send an all cases survey email to a user
  #
  class SendAllCasesSurveyJob < ApplicationJob
    class UnsupportedCaseStateError < StandardError
      attr_reader :case_ref, :case_state

      def initialize(case_ref:, case_state:)
        super
        @case_ref = case_ref
        @case_state = case_state
      end

      def message
        "Case #{case_ref} is in an unsupported state: #{case_state}"
      end
    end

    queue_as :support

    discard_on(UnsupportedCaseStateError) do |_job, error|
      Rollbar.error(error)
    end

    def perform(case_ref)
      kase = Case.find_by_ref(case_ref)

      survey = AllCasesSurveyResponse.create!(
        case: kase,
        status: :sent_out,
      )

      email = get_email_type(kase)

      email.new(
        recipient: kase,
        reference: case_ref,
        survey_id: survey.id,
      ).call

      update_case(kase)
    end

  private

    def get_email_type(kase)
      case kase.state
      when "opened", "on_hold"
        ::Emails::AllCasesSurveyOpen
      when "resolved"
        ::Emails::AllCasesSurveyResolved
      else
        raise UnsupportedCaseStateError.new(case_ref: kase.ref, case_state: kase.state)
      end
    end

    def update_case(kase)
      note = case kase.state
             when "opened", "on_hold"
               "support.interaction.message.all_cases_open_survey_sent"
             when "resolved"
               "support.interaction.message.all_cases_resolved_survey_sent"
             end

      kase.interactions.note.build(body: I18n.t(note))
      kase.save!
    end
  end
end
