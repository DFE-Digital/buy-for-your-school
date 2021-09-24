class TaskPresenter < BasePresenter
  # @see views/journeys/show
  #
  # @return [StepPresenter]
  def step
    StepPresenter.new(*steps.visible)
  end

  # @return [Boolean]
  def one_step?
    steps.visible.one?
  end

  # @return [Boolean]
  def many_steps?
    steps.visible.count > 1
  end

  # @return [Boolean]
  def not_started?
    status == Task::NOT_STARTED
  end

  # @return [Boolean]
  def in_progress?
    status == Task::IN_PROGRESS
  end

  # @return [Boolean]
  def completed?
    status == Task::COMPLETED
  end

  # @return [String]
  def status_id
    "#{id}-status"
  end
end
