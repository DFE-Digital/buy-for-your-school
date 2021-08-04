class TasksController < ApplicationController
  before_action :redirect_to_first_step_if_task_has_no_answers, only: [:show]

  # Log 'view_task'
  #
  # @see StepPresenter
  def show
    @journey = current_journey

    @current_task = task
    @next_task = current_journey.next_incomplete_task(task)

    @steps = task.eager_loaded_visible_steps.map do |step|
      StepPresenter.new(step)
    end

    RecordAction.new(
      action: "view_task",
      journey_id: @journey.id,
      user_id: current_user.id,
      contentful_category_id: @journey.category.contentful_id,
      contentful_section_id: task.section.contentful_id,
      contentful_task_id: task.contentful_id,
      data: {
        task_status: task.status,
        task_step_tally: task.step_tally,
      },
    ).call
  end

private

  # @return [Task]
  def task
    @task ||= Task.find(task_id)
  end

  # @return [String]
  def task_id
    params[:id]
  end

  # Log 'begin_task'
  #
  def redirect_to_first_step_if_task_has_no_answers
    return unless task.tally_for(:completed).zero?
    return if params.fetch(:back_link, nil).present?

    @journey = current_journey

    RecordAction.new(
      action: "begin_task",
      journey_id: @journey.id,
      user_id: current_user.id,
      contentful_category_id: @journey.category.contentful_id,
      contentful_section_id: task.section.contentful_id,
      contentful_task_id: task.contentful_id,
      data: {
        task_status: task.status,
        task_step_tally: task.step_tally,
      },
    ).call

    redirect_to journey_step_path(current_journey, task.next_incomplete_step_id)
  end
end
