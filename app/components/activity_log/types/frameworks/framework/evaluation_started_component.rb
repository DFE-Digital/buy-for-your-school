# frozen_string_literal: true

class ActivityLog::Types::Frameworks::Framework::EvaluationStartedComponent < ViewComponent::Base
  include ActivityLog::Types::BasicActivityDetails

  def initialize(activity_log_item:)
    @activity_log_item = activity_log_item
  end

  def evaluation
    Frameworks::Evaluation.find(@activity_log_item.activity.data["evaluation_id"])
  end

  delegate :reference, to: :evaluation, prefix: true
end
