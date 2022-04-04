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
        assign_agent_to_case

        redirect_to support_case_path(current_case, anchor: "case-history"),
                    notice: I18n.t("support.case_assignment.flash.created")
      else
        render :new
      end
    end

  private

    def assign_agent_to_case
      current_case.interactions.note.build(
        body: "Case assigned: New assignee is #{@case_assignment_form.new_agent.full_name}",
        agent_id: current_agent.id,
      )

      record_action(case_id: current_case.id, action: "open_case") if current_case.initial?
      current_case.open if current_case.may_open?

      current_case.update!(
        agent_id: @case_assignment_form.agent_id,
      )
    end

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
