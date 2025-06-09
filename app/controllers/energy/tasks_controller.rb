module Energy
  class TasksController < Energy::ApplicationController
    before_action :organisation_details
    before_action :switching_energy_type_not_selected?
    before_action :set_task_list
    before_action { @back_url = request.referer || energy_case_tasks_path }
    def show; end

    def update
      if all_tasks_complete?
        redirect_to energy_case_check_your_answers_path
      else
        flash[:error] = { message: I18n.t("energy.tasks.error"), class: "govuk-error" }
        render :show
        flash.clear
      end
    end

  private

    def set_task_list
      @task_list = Energy::TaskList.new(@onboarding_case_organisation.energy_onboarding_case_id).call
    end

    def switching_energy_type_not_selected?
      redirect_to energy_case_switch_energy_path(case_id: @onboarding_case_organisation.energy_onboarding_case_id) if @onboarding_case_organisation.switching_energy_type.nil?
    end

    def all_tasks_complete?
      incomplete_tasks = @task_list.select { |task| %i[in_progress not_started].include?(task.status) }

      incomplete_tasks.none?
    end

    def authenticate_user!
      return unless current_user.guest?

      session.delete(:energy_case_tasks_path)
      session[:energy_case_tasks_path] = energy_case_tasks_path(case_id: params[:case_id]) if params[:case_id].present?

      redirect_to energy_onboarding_path
    end
  end
end
