class TasksController < ApplicationController
  before_action :redirect_to_first_step_if_task_has_no_answers, only: [:show]

  def show
    @journey = current_journey
    @task = Task.find(task_id)
    steps = @task.eager_loaded_visible_steps
    @steps = steps.map { |step| StepPresenter.new(step) }
  end

  private

  def task
    @task ||= Task.find(task_id)
  end

  def task_id
    params[:id]
  end

  def redirect_to_first_step_if_task_has_no_answers
    return unless task.answered_questions_count.zero?
    return if params.fetch(:back_link, nil).present?

    redirect_to journey_step_path(current_journey, task.next_unanswered_step_id)
  end
end
