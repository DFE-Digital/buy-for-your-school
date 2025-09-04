# :nocov:
module Support
  class Cases::OrganisationsController < Cases::ApplicationController
    before_action { @back_url = support_case_path(params[:case_id]) }

    def edit
      @case_organisation_form = CaseOrganisationForm.new
    end

    def update
      @case_organisation_form = CaseOrganisationForm.from_validation(validation)

      if validation.success?
        if !current_case.participating_schools.empty?
          redirect_to support_case_confirm_organisation_path(current_case, id: @case_organisation_form.organisation_id, type: @case_organisation_form.organisation_type)
        else
          @case_organisation_form.assign_organisation_to_case(current_case, current_agent.id)

          redirect_to portal_support_case_path(current_case, anchor: "school-details"), notice: I18n.t("support.case_organisation.flash.updated")
        end
      else
        render :edit
      end
    end

  private

    def validation
      CaseOrganisationFormSchema.new.call(**case_organisation_form_params)
    end

    def case_organisation_form_params
      params.require(:case_organisation_form).permit(:organisation_id, :organisation_type)
    end

    helper_method def portal_support_case_path(current_case, anchor: nil)
      if (current_agent.roles & %w[cec cec_admin]).any?
        send("cec_onboarding_case_path", current_case, anchor:)
      else
        send("support_case_path", current_case, anchor:)
      end
    end
  end
end
# :nocov:
