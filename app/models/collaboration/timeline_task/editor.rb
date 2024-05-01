class Collaboration::TimelineTask::Editor
  include ActiveModel::Model
  include ActiveModel::Validations

  validate :valid_timeframe, if: :timeframe_changed?

  attr_accessor(
    :timeline_task,
    :title,
    :timeframe_type,
    :start_date,
    :end_date,
    :duration,
  )

  def initialize(attributes = {})
    super
    @start_date = Date.civil(@start_date["year"].to_i, @start_date["month"].to_i, @start_date["day"].to_i) if @start_date.is_a?(Hash)
    @end_date = Date.civil(@end_date["year"].to_i, @end_date["month"].to_i, @end_date["day"].to_i) if @end_date.is_a?(Hash)
    @duration = @duration.to_i
  end

  def save!
    timeline_task.transaction do
      # byebug
      timeline_task.edit(title:)
      @timeline_adjustor.perform_adjustment!
    end
  end

private

  def timeframe_changed?
    timeline_task.start_date != start_date || timeline_task.end_date != end_date || timeline_task.duration_int != duration
  end

  def valid_timeframe
    @timeline_adjustor =
      if timeframe_type == "date_range"
        timeline_adjustor(start_date:, end_date:)
      else
        end_date = duration.business_days.after(start_date)
        timeline_adjustor(start_date:, end_date:)
      end

    return if @timeline_adjustor.valid?

    @timeline_adjustor.errors.each { |error| errors.add(error) }
  end

  def timeline_adjustor(start_date:, end_date:)
    timeline_task.timeline.adjustor_by_updated_task(task: timeline_task, new_start_date: start_date, new_end_date: end_date)
  end
end
