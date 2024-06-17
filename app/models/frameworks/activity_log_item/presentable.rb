module Frameworks::ActivityLogItem::Presentable
  extend ActiveSupport::Concern

  def display_subject
    "#{subject.try(:activity_log_display_type)} #{subject.try(:reference)}"
  end

  def display_created_at
    created_at.strftime("%d %B %Y at %H:%M:%S")
  end

  def display_actor
    actor.try(:full_name)
  end
end
