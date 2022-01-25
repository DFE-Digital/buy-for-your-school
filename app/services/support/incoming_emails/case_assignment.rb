module Support
  module IncomingEmails
    class CaseAssignment
      def self.detect_and_assign_case(email)
        email.case = new(email: email).case_for_email
      end

      attr_reader :email

      def initialize(email:)
        @email = email
      end

      def case_for_email
        case_reference = case_reference_from_subject
        case_reference ||= case_reference_from_body
        case_reference ||= case_reference_from_conversation

        found_case = Support::Case.find_by(ref: case_reference) if case_reference.present?
        found_case || new_case_for_email
      end

      def case_reference_from_subject
        email.subject.match(/^(Re: )?Case ([0-9]{6,6})/).to_a.last
      end

      def case_reference_from_body
        email.body.match(/Your reference number is: ([0-9]{6,6})\. Please quote this number/).to_a.last
      end

      def case_reference_from_conversation
        other_email = Support::Email
          .where(outlook_conversation_id: email.outlook_conversation_id)
          .where.not(case_id: nil)
          .order("sent_at ASC")
          .first

        if other_email.present?
          other_email.case.try(:ref)
        end
      end

      def new_case_for_email
        Support::CreateCase.new(
          source: :incoming_email,
          email: email.sender["address"],
          action_required: true,
        ).call
      end
    end
  end
end
