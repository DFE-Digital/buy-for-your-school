class TasksController < ApplicationController
  before_action :redirect_to_first_step_if_task_has_no_answers, only: [:show]

  def show
    @journey = current_journey
    @current_task = task
    steps = @current_task.eager_loaded_visible_steps.ordered
    @steps = steps.map { |step| StepPresenter.new(step) }
    @next_task = next_task
  end

  private

  def task
    @task ||= Task.find(task_id)
  end

  def task_id
    params[:id]
  end

  def next_task
    next_task_id = current_journey.tasks.find_index { |t| t.id == task_id } + 1
    current_journey.tasks[next_task_id]
  end

  def redirect_to_first_step_if_task_has_no_answers
    return unless task.answered_questions_count.zero?
    return if params.fetch(:back_link, nil).present?

    redirect_to journey_step_path(current_journey, task.next_unanswered_step_id)
  end
end
