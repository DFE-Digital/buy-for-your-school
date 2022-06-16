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

        redirect_to support_case_path(current_case), notice: I18n.t("support.case_resolution.flash.created")
      else
        render :new
      end
    end

  private

    def validation
      CaseResolutionFormSchema.new.call(**case_resolution_form_params)
    end

    def case_resolution_form_params
      params.require(:case_resolution_form).permit(:notes)
    end

    def send_exit_survey
      unless current_case.exit_survey_sent
        if exit_survey_delay.present?
          SendExitSurveyJob.set(wait: exit_survey_delay.to_i.minutes).perform_later(current_case.ref)
        else
          SendExitSurveyJob.perform_now(current_case.ref)
        end
      end
    end

    def exit_survey_delay
      ENV["EXIT_SURVEY_EMAIL_DELAY"]
    end
  end
end
