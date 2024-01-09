module Frameworks::Evaluation::StatusChangeable
  extend ActiveSupport::Concern

  included do
    include AASM

    after_create_commit :after_drafting_of_evaluation, if: :draft?

    before_save :call_permissable_event_for_manual_updates, if: -> { status_changed? && (aasm.from_state.nil? || aasm.to_state.nil?) }

    enum status: {
      draft: 0,
      in_progress: 1,
      approved: 2,
      not_approved: 3,
      cancelled: 4,
    }

    aasm column: :status, enum: true do
      Frameworks::Evaluation.statuses.each_key { |status| state status.to_sym }

      event :mark_as_in_progress do
        transitions from: :draft, to: :in_progress, after: :after_starting_evaluation
      end

      event :mark_as_approved do
        transitions from: :in_progress, to: :approved, after: :after_approving
      end

      event :mark_as_not_approved do
        transitions from: :in_progress, to: :not_approved, after: :after_disapproving
      end

      event :mark_as_cancelled do
        transitions from: :in_progress, to: :cancelled, after: :after_cancelling
      end
    end

    scope :active, -> { where(status: %i[draft in_progress]) }
    scope :other_active_evaluations_for, ->(evaluation) { active.where.not(id: evaluation.id).where(framework: evaluation.framework) }

    validate :framework_has_no_other_active_evaliations
  end

  def permissible_status_change_options(prepend_current_status: false)
    option_for_status = ->(status) { self.class.aasm.states_for_select.find { |select| select.last == status.to_s } }

    options = aasm.permitted_transitions.map do |transition|
      option_for_status.call(transition[:state])
    end

    prepend_current_status ? options.prepend(option_for_status.call(status)) : options
  end

  def able_to_change_status?
    permissible_status_change_options.any?
  end

private

  def framework_has_no_other_active_evaliations
    errors.add(:framework, "Framework is already in active evaluation") if self.class.other_active_evaluations_for(self).any?
  end

  def after_drafting_of_evaluation
    framework.draft_evaluation!(self)
  end

  def after_starting_evaluation
    framework.start_evaluation!(self)
  end

  def after_approving
    framework.approve_evaluation!(self)
  end

  def after_disapproving
    framework.disapprove_evaluation!(self)
  end

  def after_cancelling
    framework.cancel_evaluation!(self)
  end

  def call_permissable_event_for_manual_updates
    from_status, to_status = changes["status"]

    # Set AASM to the status we have changed from (it is currently empty)
    aasm.current_state = from_status

    # Find the event we would have manually fired for the same effect
    transition_for_status_change = aasm.permitted_transitions.find { |transition| transition[:state] == to_status.to_sym }

    # Fire the event to ensure our callbacks are triggered
    aasm.fire(transition_for_status_change[:event]) if aasm.may_fire_event?(transition_for_status_change[:event])
  end
end
