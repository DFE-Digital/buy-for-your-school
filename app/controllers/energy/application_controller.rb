module Energy
  class ApplicationController < ::ApplicationController
    before_action :check_flag

    ALLOWED_CLASSES = [
      "Support::Organisation",
      "Support::EstablishmentGroup",
    ].freeze

  private

    def check_flag
      render "errors/not_found", status: :not_found unless Flipper.enabled?(:energy)
    end

    def onboarding_case
      @onboarding_case ||= Energy::OnboardingCase.find(params[:case_id])
    end

    def organisation_details(id = params[:case_id])
      @onboarding_case_organisation = Energy::OnboardingCaseOrganisation.find_by(energy_onboarding_case_id: id)
      onboardable_type = @onboarding_case_organisation.onboardable_type

      if ALLOWED_CLASSES.include?(onboardable_type)
        @organisation_detail = onboardable_type.safe_constantize.find(@onboarding_case_organisation.onboardable_id)
        user_has_access_to_organisation?
      else
        render("errors/not_found", status: :not_found)
      end
    end

    def user_has_access_to_organisation?
      valid_orgs = current_user.orgs.pluck("urn", "uid").flatten.compact

      if @organisation_detail.respond_to?(:urn) && !valid_orgs.include?(@organisation_detail.urn)
        render("errors/not_found", status: :not_found)
      elsif @organisation_detail.respond_to?(:uid) && !valid_orgs.include?(@organisation_detail.uid)
        render("errors/not_found", status: :not_found)
      end
    end
  end
end
