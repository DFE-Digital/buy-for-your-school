module Frameworks::ActivityLogItem::Presentable
  extend ActiveSupport::Concern

  def activity_type_identifier
    activity_type.demodulize.underscore
  end

  def subject_type_identifier
    subject_type.demodulize.underscore
  end

  def display_subject
    "#{subject.try(:activity_log_display_type)} #{subject.try(:activity_log_display_short_name)}"
  end

  def display_created_at
    created_at.strftime("%d/%m/%Y %H:%M:%S")
  end

  def display_actor
    actor.try(:full_name)
  end
end
