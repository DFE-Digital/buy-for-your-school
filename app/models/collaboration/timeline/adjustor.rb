class Collaboration::Timeline::Adjustor
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks

  before_validation :adjust_tasks
  # validate :timeline_start_date_bounds

  attr_accessor(
    :timeline,
    :task,
    :new_start_date,
    :new_end_date,
    :is_new_task,
  )

  def initialize(attributes = {})
    super
    @adjusted_tasks = []
  end

  def self.by_updated_task(timeline:, task:, new_start_date:, new_end_date:)
    new(timeline:, task:, new_start_date:, new_end_date:)
  end

  def self.by_new_task(timeline:, task:, new_start_date:, new_end_date:)
    new(timeline:, task:, new_start_date:, new_end_date:, is_new_task: true)
  end

  def perform_adjustment!
    timeline.transaction do
      @adjusted_tasks.each(&:save!)
    end
  end

private

  def adjust_tasks
    original_duration = task.duration_int
    new_duration = new_start_date.business_days_until(new_end_date).days
    duration_difference = original_duration - new_duration.in_days.to_i
    original_task = task.dup
    task.start_date = new_start_date
    task.end_date = new_end_date
    task.duration = new_duration
    @adjusted_tasks << task
    return if duration_difference.zero? && !is_new_task

    previous_task = task
    timeline.tasks_before(original_task).each_with_index do |past_task, index|
      break if index.zero? && !previous_task.overlaps?(past_task)

      # original_gap_between_dates = past_task.end_date.to_date.business_days_until(previous_task.start_date_was).business_days
      original_dur = past_task.end_date.to_date.business_days_until(previous_task.start_date_was).business_days
      new_dur = past_task.end_date.to_date.business_days_until(previous_task.start_date).business_days
      new_dur = (new_dur.days - original_dur.days).business_days if new_dur > original_dur
      past_task.end_date = new_dur.before(previous_task.start_date)
      past_task.start_date = past_task.duration_int.business_days.before(past_task.end_date)
      @adjusted_tasks << past_task
      previous_task = past_task
    end

    previous_task = task
    timeline.tasks_after(original_task).each_with_index do |future_task, index|
      break if index.zero? && !previous_task.overlaps?(future_task)

      original_dur = previous_task.end_date_was.to_date.business_days_until(future_task.start_date).business_days
      new_dur = previous_task.end_date.to_date.business_days_until(future_task.start_date).business_days
      new_dur = (new_dur.days - original_dur.days).business_days if new_dur > original_dur
      future_task.start_date = new_dur.after(previous_task.end_date)
      future_task.end_date = future_task.duration_int.business_days.after(future_task.start_date)
      @adjusted_tasks << future_task
      previous_task = future_task
    end
  end

  def timeline_start_date_bounds
    errors.add(:base, "The time frame exceeds the start date of the timeline") if new_start_date < timeline.start_date
  end
end
