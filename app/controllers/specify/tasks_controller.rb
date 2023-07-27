class Specify::TasksController < Specify::ApplicationController
  before_action :redirect_to_first_step_if_task_has_no_answers, only: [:show]

  # Log 'view_task'
  #
  # @see StepPresenter
  def show
    @journey = current_journey
    @back_url = journey_path(@journey)

    @current_task = task
    @next_task = current_journey.next_incomplete_task(task)

    @steps = task.eager_loaded_visible_steps.map do |step|
      StepPresenter.new(step)
    end
    record_action("view_task")
  end

private

  # @return [Task]
  def task
    @task ||= TaskPresenter.new(Task.find(task_id))
  end

  # @return [String]
  def task_id
    params[:id]
  end

  # Log 'begin_task'
  #
  def redirect_to_first_step_if_task_has_no_answers
    return unless task.tally_for(:completed).zero?
    return unless params[:back_link].nil? && params[:last_step].nil?

    @journey = current_journey

    record_action("begin_task")

    redirect_to journey_step_path(current_journey, task.next_incomplete_step_id)
  end

  def record_action(action)
    RecordAction.new(
      action:,
      journey_id: @journey.id,
      user_id: current_user.id,
      contentful_category_id: @journey.category.contentful_id,
      contentful_category: @journey.category.title,
      contentful_section_id: task.section.contentful_id,
      contentful_section: task.section.title,
      contentful_task_id: task.contentful_id,
      contentful_task: task.title,
      data: {
        task_status: task.status,
        task_step_tally: task.step_tally,
      },
    ).call
  end
end
