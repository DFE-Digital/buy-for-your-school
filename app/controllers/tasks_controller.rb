class TasksController < ApplicationController
  before_action :redirect_to_first_step_if_task_has_no_answers, only: [:show]

  def show
    @journey = current_journey
    @task = task
    steps = @task.visible_steps.includes([
      :short_text_answer,
      :long_text_answer,
      :radio_answer,
      :checkbox_answers,
      :currency_answer,
      :number_answer,
      :single_date_answer
    ])
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
