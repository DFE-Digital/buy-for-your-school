module Support::Case::StateChangeable
  extend ActiveSupport::Concern

  included do
    include AASM

    enum state: {
      initial: 0,
      opened: 1,
      resolved: 2,
      on_hold: 3,
      closed: 4,
      pipeline: 5,
      no_response: 6,
    }

    aasm(column: :state, enum: true) do
      state :initial, initial: true
      state :opened, :resolved, :on_hold, :closed, :pipeline, :no_response

      after_all_transitions :record_state_change_in_activity_log
      after_all_transitions :broadcast_state_change_on_cable

      event :resolve do
        transitions from: :initial, to: :resolved
        transitions from: :opened, to: :resolved
      end

      event :open do
        transitions from: :initial, to: :opened
        transitions from: :resolved, to: :opened
        transitions from: :on_hold, to: :opened
        transitions from: :closed, to: :opened
      end

      event :reopen_due_to_incoming_email, after: :log_reopened_due_to_incoming_email do
        transitions from: :resolved, to: :opened
        transitions from: :on_hold, to: :opened
      end

      event :hold do
        transitions from: :opened, to: :on_hold
        transitions from: :initial, to: :on_hold
      end

      event :hold_due_to_contact_with_school, after: :log_held_due_to_contact_with_school do
        transitions from: :initial, to: :on_hold
      end

      event :close do
        transitions from: :initial, to: :closed
        transitions from: :opened, to: :closed
        transitions from: :on_hold, to: :closed
        transitions from: :resolved, to: :closed
      end
    end
  end

private

  def record_state_change_in_activity_log
    Support::RecordAction.new(case_id: id, action: "change_state", data: { old_state: aasm.from_state, new_state: aasm.to_state }).call
  end

  def broadcast_state_change_on_cable
    broadcast_replace_to "case_status_updates", partial: "support/cases/status_badge", locals: { state: aasm.to_state }, target: "case_status_badge"
  end
end
