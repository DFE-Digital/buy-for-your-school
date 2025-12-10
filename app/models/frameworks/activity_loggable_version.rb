class Frameworks::ActivityLoggableVersion < PaperTrail::Version
  include Presentable

  after_create_commit :save_default_attributes_on_item_created

  before_create do
    self.whodunnit = Current.actor.try(:email)
  end

  def field_changes
    object_changes.except("id", "created_at", "updated_at")
  end

  def exclusive_field_change
    return nil if field_changes.keys.count > 1

    field_changes.keys.first
  end

  def activity_log_event_description
    if exclusive_field_change.present?
      description_from_model = item.try(:custom_activity_log_event_description_for, self)
      description_from_model || "#{exclusive_field_change.split('_id').first}_updated"
    else
      "record_#{event}d"
    end
  end

  def changed_fields_only?(*fields)
    field_changes.keys == Array(fields)
  end

  def changed_fields_including?(*fields)
    field_changes.keys.intersection(Array(fields)).any?
  end

  def item_association_at_version_or_current(association:, id:, version_at: created_at)
    reflection = item.class.reflections[association]
    return nil unless reflection

    current_version_of_association = reflection.klass.find_by(id:)
    current_version_of_association.try(:version_at, version_at).presence || current_version_of_association
  end

private

  def save_default_attributes_on_item_created
    return unless item.id_previously_changed?

    object_changes_including_database_default_values = item.reload.attributes.each_with_object(object_changes) do |(attr, value), all_changes|
      all_changes[attr] ||= [nil, value]
    end

    update!(object_changes: object_changes_including_database_default_values)
  end
end
