class ActivityLog::Types::Frameworks::Evaluation::EvaluationTransferredComponent < ViewComponent::Base
  include ActivityLog::Types::BasicActivityDetails

  def initialize(activity_log_item:)
    @activity_log_item = activity_log_item
  end

  def title
    "Evaluation Transferred"
  end

  def source
    source_id   = @activity_log_item.activity.activity.data["source_id"]
    source_type = @activity_log_item.activity.activity.data["source_type"]

    source_type.safe_constantize.find(source_id) if source_id && source_type
  end
end
