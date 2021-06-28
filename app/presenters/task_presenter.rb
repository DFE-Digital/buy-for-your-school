class TaskPresenter < SimpleDelegator
  # @see views/journeys/show
  #
  def step
    StepPresenter.new(*visible_steps)
  end

  def one_step?
    visible_steps.one?
  end

  def many_steps?
    visible_steps.count > 1
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
