module Collaboration
  class TimelineTask < ApplicationRecord
    include Editable

    belongs_to :stage, class_name: "Collaboration::TimelineStage", foreign_key: :timeline_stage_id

    before_save :update_time_frame, if: :time_frame_needs_update?
    after_save :update_stage_complete_by

    delegate :timeline, to: :stage, allow_nil: true

    def time_frame
      start_date_format = start_date.month == end_date.month && start_date.year == end_date.year ? "%-d" : "%-d %B"
      end_date_format = "%-d %B %Y"
      start_date_formatted = start_date.strftime(start_date_format)
      end_date_formatted = end_date.strftime(end_date_format)
      "#{start_date_formatted} to #{end_date_formatted} (#{duration_int} working #{'day'.pluralize(duration_int)})"
    end

    def overlaps?(task)
      !(end_date < task.start_date || task.end_date < start_date)
    end

    def duration_int
      return if duration.blank?

      duration.in_days.to_i
    end

  private

    def update_stage_complete_by
      last_task = stage.tasks.last
      stage.refresh_complete_by! if last_task == self
    end

    def time_frame_needs_update?
      duration.blank? || start_date.blank? || end_date.blank?
    end

    def update_time_frame
      if start_date.present? && end_date.present?
        self.duration = start_date.to_date.business_days_until(end_date.to_date)
      elsif start_date.present? && duration.present?
        self.end_date = duration_int.business_days.after(start_date.to_date)
      elsif duration.present?
        self.start_date = timeline.tasks.present? ? timeline.tasks.last.end_date + 1.day : timeline.start_date
        self.end_date = duration_int.business_days.after(start_date.to_date)
      end
    end
  end
end
