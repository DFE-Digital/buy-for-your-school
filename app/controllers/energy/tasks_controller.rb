module Energy
  class TasksController < Energy::ApplicationController
    before_action :organisation_details
    before_action :switching_energy_type_not_selected?
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

    def switching_energy_type_not_selected?
      redirect_to energy_case_switch_energy_path(case_id: @onboarding_case_organisation.energy_onboarding_case_id) if @onboarding_case_organisation.switching_energy_type.nil?
    end
  end
end
