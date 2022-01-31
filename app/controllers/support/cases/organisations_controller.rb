# :nocov:
module Support
  class Cases::OrganisationsController < Cases::ApplicationController
    def edit
      @case_organisation_form = CaseOrganisationForm.new
    end

    def update
      @case_organisation_form = CaseOrganisationForm.from_validation(validation)

      if validation.success? && @case_organisation_form.assign_organisation_to_case(current_case)
        redirect_to support_case_path(current_case, anchor: "school-details"),
                    notice: I18n.t("support.case_organisation.flash.updated")
      else
        render :edit
      end
    end

  private

    def validation
      CaseOrganisationFormSchema.new.call(**case_organisation_form_params)
    end

    def case_organisation_form_params
      params.require(:case_organisation_form).permit(:organisation_formatted_name)
    end
  end
end
# :nocov:
