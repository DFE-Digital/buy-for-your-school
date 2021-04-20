class TasksController < ApplicationController
  def show
    @journey = current_journey
    @task = Task.find(task_id)
  end

  private

  def task_id
    params[:id]
  end
end
