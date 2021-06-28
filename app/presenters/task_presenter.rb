class TaskPresenter < SimpleDelegator
  # @see views/journeys/show
  #
  def step
    StepPresenter.new(*steps.visible)
  end

  def one_step?
    steps.visible.one?
  end

  def many_steps?
    steps.visible.count > 1
  end

  def not_started?
    status == Task::NOT_STARTED
  end

  def in_progress?
    status == Task::IN_PROGRESS
  end

  def completed?
    status == Task::COMPLETED
  end

  def status_id
    "#{id}-status"
  end
end
