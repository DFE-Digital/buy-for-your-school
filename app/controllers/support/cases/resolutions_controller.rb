module Support
  class Cases::ResolutionsController < Cases::ApplicationController
    def new
      @case_resolution_form = CaseResolutionForm.new
    end

    def create
      @case_resolution_form = CaseResolutionForm.from_validation(validation)

      if validation.success? && !current_case.resolved?
        resolve_case

        redirect_to support_case_path(current_case), notice: I18n.t("support.case_resolution.flash.created")
      else
        render :new
      end
    end

  private

    def resolve_case
      current_case.agent = nil

      current_case.interactions.note.build(
        body: "Case resolved: #{@case_resolution_form.notes}",
        agent_id: current_agent.id,
      )

      current_case.resolved!
      record_case_resolved
    end

    def record_case_resolved
      Support::RecordSupportCaseAction.new(
        support_case_id: current_case.id,
        action: 'resolving_case',
      ).call
    end

    def validation
      CaseResolutionFormSchema.new.call(**case_resolution_form_params)
    end

    def case_resolution_form_params
      params.require(:case_resolution_form).permit(:notes)
    end
  end
end
