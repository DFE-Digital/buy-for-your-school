module Support::Case::Historyable
  extend ActiveSupport::Concern

  included do
    has_many :interactions, class_name: "Support::Interaction"

    after_create_commit :log_created_due_to_incoming_email, if: :incoming_email?

    after_update :log_with_school_changed_in_history, if: :saved_change_to_with_school?
    after_update :log_support_level_changed_in_history, if: :saved_change_to_support_level?
    after_update :log_procurement_stage_changed_in_history, if: :saved_change_to_procurement_stage_id?
    after_update :log_source_changed_in_history, if: :saved_change_to_source?
    after_update :log_value_changed_in_history, if: :saved_change_to_value?
    after_update :log_next_key_date_changed_in_history, if: -> { saved_change_to_next_key_date? || saved_change_to_next_key_date_description? }
    after_update :log_categorisation_changed_in_history, if: -> { saved_change_to_category_id? || saved_change_to_query_id? }
  end

  def add_note(body)
    interactions.note.create!(body:, agent: Current.agent)
  end

  def latest_note = interactions.note.first

protected

  def log_held_due_to_contact_with_school
    interactions.state_change.create!(body: "Case placed on hold due to making contact with school")
  end

  def log_created_due_to_incoming_email
    interactions.create_case.create!(body: "Case created due to receiving email that could not be attached to a currently open case")
  end

  def log_reopened_due_to_incoming_email
    interactions.state_change.create!(body: "Case reopened due to receiving new email")
  end

  def log_categorisation_changed_in_history
    if saved_change_to_category_id? && saved_change_to_query_id?
      log_change_of_category_and_query
    elsif saved_change_to_category_id?
      log_change_of_category
    elsif saved_change_to_query_id?
      log_change_of_query
    end
  end

  def log_source_changed_in_history
    interactions.state_change.create!(
      additional_data: { source:, format_version: "2" },
      agent: Current.agent,
      body: "Source changed",
    )
  end

  def log_value_changed_in_history
    interactions.state_change.create!(
      additional_data: { procurement_value: value, format_version: "2" },
      agent: Current.agent,
      body: "Case value changed",
    )
  end

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

  def log_next_key_date_changed_in_history
    interactions.case_next_key_date_changed.create!(
      additional_data: {
        next_key_date:,
        next_key_date_description:,
      },
      agent: Current.agent,
      body: "Next key date change",
    )
  end

private

  def additional_data_from_changes_to(field)
    changes = saved_changes[field]
    { from: changes.first, to: changes.last }
  end

  def log_change_of_category
    log_categorisation_change(**additional_data_from_changes_to(:category_id), type: :category)
  end

  def log_change_of_query
    log_categorisation_change(**additional_data_from_changes_to(:query_id), type: :query)
  end

  def log_change_of_category_and_query
    category_from, category_to = additional_data_from_changes_to(:category_id).values
    query_from, query_to       = additional_data_from_changes_to(:query_id).values

    if category_from.present? && category_to.nil? && query_to.present?
      log_categorisation_change(from: category_from, to: query_to, type: :category_to_query)
    elsif query_from.present? && query_to.nil? && category_to.present?
      log_categorisation_change(from: query_from, to: category_to, type: :query_to_category)
    end
  end

  def log_categorisation_change(from:, to:, type:)
    interactions.case_categorisation_changed.create!(
      additional_data: { from:, to:, type: },
      agent: Current.agent,
      body: "Categorisation change",
    )
  end
end
