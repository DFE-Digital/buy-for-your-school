class ActivityLog::Types::NoteAddedComponent < ViewComponent::Base
  include ActivityLog::Types::BasicActivityDetails

  def initialize(activity_log_item:)
    @activity_log_item = activity_log_item
  end

  def title
    "Note Added"
  end

  def note
    @activity_log_item.activity.data["body"]
  end
end
