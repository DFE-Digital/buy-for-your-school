module Frameworks::Framework::StatusChangeable
  extend ActiveSupport::Concern

  included do
    include AASM

    enum status: {
      pending_evaluation: 0,
      evaluating: 1,
      not_approved: 2,
      dfe_approved: 3,
      cab_approved: 4,
    }

    aasm column: :status, enum: true do
      Frameworks::Framework.statuses.each { |status, _| state status.to_sym }

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
