module Support
  class Cases::ClosuresController < Cases::ApplicationController
    class CaseCannotBeClosed < StandardError; end

    before_action :set_reasons, only: %i[index confirm]

    def index
      unless current_case.opened? || (current_case.initial? && current_case.incoming_email?)
        return redirect_to redirect_path, notice: I18n.t("support.case_closures.flash.error.initial")
      end

      @back_url = case_closures_cancel_path
      @case_closure_form = CaseClosureForm.new
    end

    def confirm
      @case_closure_form = CaseClosureForm.from_validation(validation)
      if validation.success?
        @back_url = case_closures_path
        @current_case = CasePresenter.new(@current_case)
        @reason = @case_closure_form.reason
        render :confirm
      else
        render :index
      end
    end

    def create
      @case_closure_form = CaseClosureForm.from_validation(validation)
      if validation.success?
        current_case.transaction do
          raise CaseCannotBeClosed unless current_case.opened? || (current_case.initial? && current_case.incoming_email?)

          reason = I18n.t("support.case_closures.edit.reasons.#{@case_closure_form.reason}")
          change_case_state(
            to: :close,
            reason: @case_closure_form.reason,
            body: "From #{I18n.t("support.case.label.state.state_#{current_case.state}").downcase} to rejected by #{current_agent.full_name} on #{Time.zone.now.to_formatted_s(:short)}. Reason given: #{reason}",
          )
        end
        record_action(case_id: current_case.id, action: "close_case", data: { closure_reason: @case_closure_form.reason })
        current_case.notify_agent_of_case_closed if current_case.agent.present?
        redirect_to redirect_path, notice: I18n.t("support.case_closures.flash.updated")
      else
        render :index
      end
    rescue CaseCannotBeClosed
      redirect_to redirect_path, notice: I18n.t("support.case_closures.flash.error.initial")
    end

  private

    def authorize_agent_scope = :access_individual_cases?

    def set_reasons
      @reasons = %i[no_engagement spam out_of_scope test_case other]
    end

    def validation
      CaseClosureFormSchema.new.call(**case_closure_form_params)
    end

    def case_closure_form_params
      params.require(:case_closure_form).permit(:reason)
    end

    def redirect_path
      is_user_cec_agent? ? cec_onboarding_cases_path : support_cases_path
    end

    helper_method def case_closures_path
      is_user_cec_agent? ? cec_case_closures_path : support_case_closures_path
    end

    helper_method def portal_case_closures_path(current_case)
      send("#{agent_portal_namespace}_case_closures_path", current_case)
    end

    helper_method def case_closures_cancel_path
      is_user_cec_agent? ? cec_onboarding_case_path(@current_case, anchor: "case-details") : support_case_path(@current_case, anchor: "case-details")
    end

    helper_method def portal_case_closures_confirm_path(current_case)
      send("#{agent_portal_namespace}_case_closures_confirm_path", current_case)
    end
  end
end
