# frozen_string_literal: true

class ActivityLog::Types::CategoryAddedComponent < ViewComponent::Base
  include ActivityLog::Types::BasicActivityDetails

  def initialize(activity_log_item:)
    @activity_log_item = activity_log_item
  end

  def title
    "Category #{category_name} added"
  end

  def category_name
    Support::Category.find(@activity_log_item.activity.data["support_category_id"]).try(:title)
  end
end
