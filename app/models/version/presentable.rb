module Version::Presentable
  extend ActiveSupport::Concern

  def presentable_changes
    Version::PresentableChanges.new(self)
  end

  def display_field_version(field:, value:)
    display_value =
      if field.ends_with?("_id")
        display_field_version_for_association(association: field.split("_id").first, id: value)
      else
        item.try("display_field_version_#{field}", value)
      end

    display_value.presence || value
  end

  def display_field_version_for_association(association:, id:)
    record = item_association_at_version_or_current(association:, id:)
    record.try(:activity_log_display_name).presence || record.try(:full_name).presence || record.try(:name)
  end
end
