module Support
  class Cases::AssignmentsController < Cases::ApplicationController
    before_action :set_back_url

    def index
      respond_to do |format|
        format.json do
          render json: Agent.omnisearch(params[:q]).map { |a| AgentPresenter.new(a) }.as_json
        end
      end
    end

    def new
      @case_assignment_form = CaseAssignmentForm.new
    end

    def create
      @case_assignment_form = CaseAssignmentForm.from_validation(validation)

      if validation.success?
        CaseManagement::AssignCaseToAgent.new.call(
          support_case_id: current_case.id,
          assigned_by_agent_id: current_agent.id,
          assigned_to_agent_id: @case_assignment_form.agent_id,
        )

        redirect_to support_case_path(current_case, anchor: "case-history"),
                    notice: I18n.t("support.case_assignment.flash.created")
      else
        render :new
      end
    end

  private

    def validation
      CaseAssignmentFormSchema.new.call(**case_assignment_form_params)
    end

    def case_assignment_form_params
      params.require(:case_assignment_form).permit(:agent_id)
    end

    def set_back_url
      @back_url = support_case_path(current_case)
    end
  end
end
