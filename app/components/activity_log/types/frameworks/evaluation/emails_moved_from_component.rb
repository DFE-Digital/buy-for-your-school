# frozen_string_literal: true

class ActivityLog::Types::Frameworks::Evaluation::EmailsMovedFromComponent < ViewComponent::Base
  include ActivityLog::Types::BasicActivityDetails

  def initialize(activity_log_item:)
    @activity_log_item = activity_log_item
  end

  def from_case_reference
    from_case.try(:reference)
  end

  def from_case
    source_id   = @activity_log_item.activity.data["source_id"]
    source_type = @activity_log_item.activity.data["source_type"]

    source_type.safe_constantize.find(source_id) if source_id && source_type
  end
end
