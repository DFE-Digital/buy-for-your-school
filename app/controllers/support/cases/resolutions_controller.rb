module Support
  class Cases::ResolutionsController < ApplicationController
    before_action :current_case

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
    end

    def validation
      CaseResolutionFormSchema.new.call(**case_resolution_form_params)
    end

    def case_resolution_form_params
      params.require(:case_resolution_form).permit(:notes)
    end

    def current_case
      @current_case ||= Case.find_by(id: params[:case_id])
    end
  end
end
