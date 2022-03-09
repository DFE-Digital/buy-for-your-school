module Support
  class Cases::ResolutionsController < Cases::ApplicationController
    def new
      @case_resolution_form = CaseResolutionForm.new
    end

    def create
      @case_resolution_form = CaseResolutionForm.from_validation(validation)

      if validation.success? && !current_case.resolved?
        resolve_case

        record_action(case_id: current_case.id, action: "resolve_case")

        redirect_to support_case_path(current_case), notice: I18n.t("support.case_resolution.flash.created")
      else
        render :new
      end
    end

  private

    def resolve_case
      current_case.interactions.state_change.build(
        body: "#{state_change_body('resolved')}: #{@case_resolution_form.notes}",
        agent_id: current_agent.id,
      )

      current_case.resolve!
    end

    def validation
      CaseResolutionFormSchema.new.call(**case_resolution_form_params)
    end

    def case_resolution_form_params
      params.require(:case_resolution_form).permit(:notes)
    end
  end
end
