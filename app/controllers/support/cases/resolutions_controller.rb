module Support
  class Cases::ResolutionsController < ApplicationController
    before_action :current_case

    def new
      @case_resolution_form = CaseResolutionForm.new
    end

    def create
      @case_resolution_form = completed_case_resolution_form

      if validation.success? && !current_case.resolved?
        resolve_case

        redirect_to support_case_path(current_case), notice: I18n.t("support.case_resolution.flash.created")
      else
        render :new
      end
    end

  private

    def completed_case_resolution_form
      CaseResolutionForm.new(messages: validation.errors(full: true).to_h, **validation.to_h)
    end

    def resolve_case
      current_case.agent = nil

      current_case.interactions.build(
        body: "Case resolved: #{@case_resolution_form.notes}",
        event_type: :note,
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
