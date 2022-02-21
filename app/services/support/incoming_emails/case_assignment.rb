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

        return found_case if found_case && !found_case.closed?

        new_case_for_email unless email.sent_items?
      end

      def case_reference_from_subject
        email.subject.match(/(?:^| )(0[0-9]{5,5})/).to_a.last
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
        first_name, *last_name = email.sender["name"].split(" ")
        last_name = Array(last_name).join(" ")

        Support::CreateCase.new(
          source: :incoming_email,
          email: email.sender["address"],
          first_name: first_name,
          last_name: last_name,
          action_required: true,
        ).call
      end
    end
  end
end
