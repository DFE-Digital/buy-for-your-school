module Support
  class Cases::AssignmentsController < Cases::ApplicationController
    before_action :load_agents, :set_back_url

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

      current_case.update!(
        state: :opened,
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
      @back_url = support_cases_path(current_case)
    end

    def load_agents
      @agents = Agent.all.map { |a| AgentPresenter.new(a) }.sort_by(&:full_name)
    end
  end
end
