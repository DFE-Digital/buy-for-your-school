class Collaboration::TimelineTask::Creator
  include ActiveModel::Model
  include ActiveModel::Validations

  validate :valid_timeframe

  attr_accessor(
    :title,
    :timeline,
    :stage,
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
    @timeline_task = Collaboration::TimelineTask.new(title:, stage:, start_date:, end_date:, duration: duration.days, state: :draft)
  end

  def save!
    @timeline_task.transaction do
      @timeline_task.save!
      # timeline_task.edit(title:, stage:, start_date:, end_date:)
      @timeline_adjustor.perform_adjustment!
    end
  end

private

  def valid_timeframe
    @timeline_adjustor =
      if timeframe_type == "date_range"
        timeline_adjustor(start_date:, end_date:)
      else
        end_date = duration.business_days.after(start_date)
        @timeline_task.end_date = end_date
        timeline_adjustor(start_date:, end_date:)
      end

    return if @timeline_adjustor.valid?

    @timeline_adjustor.errors.each { |error| errors.add(error) }
  end

  def timeline_adjustor(start_date:, end_date:)
    timeline.adjustor_by_new_task(task: @timeline_task, new_start_date: start_date, new_end_date: end_date)
  end
end
