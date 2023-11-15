module Frameworks::Evaluation::Transferable
  extend ActiveSupport::Concern

  included do
    after_create -> { log_evaluation_transferred(source.id, source.class.name) }, if: :creation_source_transfer?
  end

  class_methods do
    def transfer_from_support_case(support_case, framework_id, assignee_id)
      transaction do
        evaluation = create!(
          creation_source: :transfer,
          source: support_case,
          framework_id:,
          assignee_id:,
        )
        support_case.emails.update_all(ticket_id: evaluation.id, ticket_type: evaluation.class.name)
        evaluation.update!(action_required: evaluation.emails.any? { |email| !email.is_read? })
        evaluation
      end
    end
  end

protected

  def log_evaluation_transferred(source_id, source_type)
    log_activity_event("evaluation_transferred", source_id:, source_type:)
  end
end
