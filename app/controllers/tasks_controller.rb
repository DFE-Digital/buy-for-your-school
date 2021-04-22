class TasksController < ApplicationController
  def show
    @journey = current_journey
    @task = Task.find(task_id)
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

  def task_id
    params[:id]
  end
end
