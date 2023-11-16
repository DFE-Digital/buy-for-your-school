module Frameworks::Framework::ActivityEventLoggable
  extend ActiveSupport::Concern

protected

  def log_framework_category_added(category)
    log_activity_event("category_added", support_category_id: category.id)
  end

  def log_framework_category_removed(category)
    log_activity_event("category_removed", support_category_id: category.id)
  end
end
