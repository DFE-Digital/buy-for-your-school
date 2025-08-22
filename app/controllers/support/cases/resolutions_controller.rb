module Support
  class Cases::ResolutionsController < Cases::ApplicationController
    def new
      @case_resolution_form = CaseResolutionForm.new
    end

    def create
      @case_resolution_form = CaseResolutionForm.from_validation(validation)

      if validation.success? && !current_case.resolved?
        change_case_state(
          to: :resolve,
          info: ": #{@case_resolution_form.notes}",
        )

        # send automated exit survey email
        send_exit_survey

        record_action(case_id: current_case.id, action: "resolve_case")

        redirect_to redirect_path, notice: I18n.t("support.case_resolution.flash.created")
      else
        render :new
      end
    end

  private

    def authorize_agent_scope = :access_individual_cases?

    def validation
      CaseResolutionFormSchema.new.call(**case_resolution_form_params)
    end

    def case_resolution_form_params
      params.require(:case_resolution_form).permit(:notes)
    end

    def send_exit_survey
      unless current_case.exit_survey_sent || current_case.energy_onboarding_case?
        SendExitSurveyJob.start(@current_case.ref)
      end
    end

    def redirect_path
      is_user_cec_agent? ? cec_onboarding_case_path(current_case) : support_case_path(current_case)
    end

    helper_method def portal_case_resolution_path(current_case)
      send("#{agent_portal_namespace}_case_resolution_path", current_case)
    end
  end
end
