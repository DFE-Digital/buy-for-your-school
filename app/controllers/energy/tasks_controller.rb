module Energy
  class TasksController < Energy::ApplicationController
    before_action :organisation_details
    before_action :set_task_list
    before_action { @back_url = request.referer || energy_case_tasks_path }
    def show; end

    def update
      render :show
    end

  private

    def set_task_list
      @task_list = Energy::TaskList.new(@onboarding_case_organisation.energy_onboarding_case_id).call
    end
  end
end
