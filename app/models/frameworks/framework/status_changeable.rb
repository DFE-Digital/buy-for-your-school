module Frameworks::Framework::StatusChangeable
  extend ActiveSupport::Concern

  included do
    include AASM

    enum :status, {
      not_approved: 0,
      pending_evaluation: 1,
      evaluating: 2,
      dfe_approved: 3,
      cab_approved: 4,
      expired: 5,
      archived: 6,
    }

    # Method to return statuses in approval order
    def self.ordered_statuses_by_approval
      %w[dfe_approved cab_approved evaluating expired not_approved pending_evaluation archived]
    end

    aasm column: :status, enum: true do
      Frameworks::Framework.ordered_statuses_by_approval.each { |status| state status.to_sym }

      event :draft_evaluation do
        transitions from: %i[not_approved], to: :pending_evaluation, after: :after_drafting_evaluation
      end

      event :start_evaluation do
        transitions from: %i[pending_evaluation not_approved], to: :evaluating, after: :after_starting_evaluation
      end

      event :approve_evaluation do
        transitions from: :evaluating, to: :dfe_approved, after: :after_approving_evaluation
      end

      event :disapprove_evaluation do
        transitions from: :evaluating, to: :not_approved, after: :after_disapproving_evaluation
      end

      event :cancel_evaluation do
        transitions from: :evaluating, to: :not_approved, after: :after_cancelling_evaluation
      end
    end
  end

private

  def after_drafting_evaluation(evaluation)
    log_activity_event("evaluation_drafted", evaluation_id: evaluation.id)
  end

  def after_starting_evaluation(evaluation)
    log_activity_event("evaluation_started", evaluation_id: evaluation.id)
  end

  def after_approving_evaluation(evaluation)
    log_activity_event("evaluation_approved", evaluation_id: evaluation.id)
  end

  def after_disapproving_evaluation(evaluation)
    log_activity_event("evaluation_not_approved", evaluation_id: evaluation.id)
  end

  def after_cancelling_evaluation(evaluation)
    log_activity_event("evaluation_cancelled", evaluation_id: evaluation.id)
  end
end
