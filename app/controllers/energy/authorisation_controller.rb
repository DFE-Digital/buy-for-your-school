module Energy
  class AuthorisationController < ApplicationController
    before_action :validate_school
    before_action { @back_url = energy_school_selection_path }

    def show; end

    def update
      return unless params[:type] == "single"

      onboarding_case = existing_onboarding_case? || create_onboarding_case
      redirect_to energy_case_switch_energy_path(case_id: onboarding_case.energy_onboarding_case_id)
    end

  private

    def existing_onboarding_case?
      Energy::OnboardingCaseOrganisation.find_by(onboardable: @support_organisation)
    end

    def create_onboarding_case
      Energy::CaseCreatable.create_case(current_user, @support_organisation)
    end

    def validate_school
      @support_organisation, valid_school_urns = support_organisation_and_valid_urns
      @school_list = Support::Organisation.where(trust_code: params[:id]) if params[:type] == "mat"

      redirect_to energy_school_selection_path unless @support_organisation && valid_school_urns.include?(params[:id])
    end

    def support_organisation_and_valid_urns
      if params[:type] == "mat"
        [
          Support::EstablishmentGroup.find_by(uid: params[:id]),
          current_user.orgs.pluck("uid"),
        ]
      else
        [
          Support::Organisation.find_by(urn: params[:id]),
          current_user.orgs.pluck("urn"),
        ]
      end
    end
  end
end
