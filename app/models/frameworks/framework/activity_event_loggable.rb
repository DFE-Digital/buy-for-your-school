module Frameworks::Framework::ActivityEventLoggable
  extend ActiveSupport::Concern

  def activity_event_data_for(activity_event)
    case activity_event.event
    when "framework_category_added", "framework_category_removed"
      { support_category: Support::Category.find(activity_event.data["support_category_id"]) }
    end
  end

protected

  def log_framework_category_added(category)
    log_activity_event("framework_category_added", support_category_id: category.id)
  end

  def log_framework_category_removed(category)
    log_activity_event("framework_category_removed", support_category_id: category.id)
  end
end
