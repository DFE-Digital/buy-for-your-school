module Support::Evaluator::Actionable
  extend ActiveSupport::Concern

  included do
    after_update_commit :set_support_case_action_required, if: :has_uploaded_documents_previously_changed?
  end

  def set_support_case_action_required
    if Flipper.enabled?(:sc_notify_procops)
      action_required = Support::Evaluator.where(support_case_id: support_case.id, has_uploaded_documents: true, evaluation_approved: false).any? || Email.where(ticket_id: support_case.id, folder: 0, is_read: false).any?
      support_case.update!(action_required:)
    end
  end
end
