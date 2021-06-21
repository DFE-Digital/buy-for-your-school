class TasksController < ApplicationController
  before_action :redirect_to_first_step_if_task_has_no_answers, only: [:show]

  def show
    @journey = current_journey
    @current_task = task
    steps = @current_task.eager_loaded_visible_steps
    @steps = steps.map { |step| StepPresenter.new(step) }
    @next_task = next_unanswered_task

    RecordAction.new(
      action: "view_task",
      journey_id: @journey.id,
      user_id: current_user.id,
      contentful_category_id: @journey.contentful_id,
      contentful_section_id: task.section.contentful_id,
      contentful_task_id: task.contentful_id,
      data: {
        task_status: task.status,
        task_total_steps: task.step_tally["visible"],
        task_answered_questions: task.step_tally["answered"]
      }
    ).call
  end

  private

  def task
    @task ||= Task.find(task_id)
  end

  def task_id
    params[:id]
  end

  def next_unanswered_task
    current_journey.tasks.order(:section_id, :order).reject(&:all_steps_answered?).last
  end

  def redirect_to_first_step_if_task_has_no_answers
    return unless task.step_tally["answered"].zero?
    return if params.fetch(:back_link, nil).present?

    @journey = current_journey

    RecordAction.new(
      action: "begin_task",
      journey_id: @journey.id,
      user_id: current_user.id,
      contentful_category_id: @journey.contentful_id,
      contentful_section_id: task.section.contentful_id,
      contentful_task_id: task.contentful_id,
      data: {
        task_status: task.status,
        task_total_steps: task.step_tally["visible"],
        task_answered_questions: task.step_tally["answered"]
      }
    ).call

    redirect_to journey_step_path(current_journey, task.next_unanswered_step_id)
  end
end
