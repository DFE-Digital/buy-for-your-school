class ActivityLog::HistoryComponent < ViewComponent::Base
  def initialize(activity_log_items:, title: "Activity")
    @activity_log_items = activity_log_items
    @title              = title
  end

  def before_render
    @history_items = @activity_log_items.map { |item| component_for(item) }
  end

private

  def component_for(activity_log_item)
    event_description = activity_log_item.event_description.classify

    subject_specific_type = "ActivityLog::Types::#{activity_log_item.subject_type}::#{event_description}Component".safe_constantize
    generic_type          = "ActivityLog::Types::#{event_description}Component".safe_constantize
    fallback_type         = ActivityLog::Types::RecordUpdatedComponent

    type = subject_specific_type || generic_type || fallback_type
    type.new(activity_log_item:)
  end
end
