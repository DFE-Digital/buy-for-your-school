module Support
  class Cases::AssignmentsController < Cases::ApplicationController
    before_action :set_back_url

    def index
      agents = cec_namespace? ? Agent.cec_omnisearch(params[:q]) : Agent.omnisearch(params[:q])

      respond_to do |format|
        format.json do
          render json: agents.map { |a| AgentPresenter.new(a) }.as_json
        end
      end
    end

    def new
      @case_assignment_form = CaseAssignmentForm.new
    end

    def create
      @case_assignment_form = CaseAssignmentForm.from_validation(validation)

      if validation.success?
        assignee = Support::Agent.find(@case_assignment_form.agent_id)
        current_case.assign_to_agent(assignee, assigned_by: current_agent.to_model)

        redirect_to redirect_path, notice: I18n.t("support.case_assignment.flash.created")
      else
        render :new
      end
    end

  private

    def cec_namespace?
      (current_agent.roles & %w[cec cec_admin]).any?
    end

    def portal_namespace
      (current_agent.roles & %w[cec cec_admin]).any? ? "cec" : "support"
    end

    def redirect_path
      if cec_namespace?
        cec_onboarding_case_path(current_case, anchor: "case-history")
      else
        support_case_path(current_case, anchor: "case-history")
      end
    end

    helper_method def portal_case_assignments_path(current_case)
      send("#{portal_namespace}_case_assignments_path", current_case)
    end

    def validation
      CaseAssignmentFormSchema.new.call(**case_assignment_form_params)
    end

    def case_assignment_form_params
      params.require(:case_assignment_form).permit(:agent_id)
    end

    def set_back_url
      @back_url = cec_namespace? ? cec_onboarding_case_path(current_case) : support_case_path(current_case)
    end
  end
end
