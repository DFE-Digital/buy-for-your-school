module Support::Case::Historyable
  extend ActiveSupport::Concern

  included do
    has_many :interactions, class_name: "Support::Interaction"

    after_update :log_with_school_changed_in_history, if: :saved_change_to_with_school?
    after_update :log_support_level_changed_in_history, if: :saved_change_to_support_level?
    after_update :log_procurement_stage_changed_in_history, if: :saved_change_to_procurement_stage_id?
  end

  def add_note(body)
    interactions.note.create!(body:, agent: Current.agent)
  end

  def latest_note = interactions.note.first

protected

  def log_support_level_changed_in_history
    interactions.case_level_changed.create!(
      additional_data: additional_data_from_changes_to(:support_level),
      agent: Current.agent,
      body: "Support level change",
    )
  end

  def log_procurement_stage_changed_in_history
    interactions.case_procurement_stage_changed.create!(
      additional_data: additional_data_from_changes_to(:procurement_stage_id),
      agent: Current.agent,
      body: "Procurement stage change",
    )
  end

  def log_with_school_changed_in_history
    interactions.case_with_school_changed.create!(
      additional_data: additional_data_from_changes_to(:with_school),
      agent: Current.agent,
      body: "'With School' flag change",
    )
  end

private

  def additional_data_from_changes_to(field)
    changes = saved_changes[field]
    { from: changes.first, to: changes.last }
  end
end
