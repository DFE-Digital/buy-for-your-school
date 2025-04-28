module Energy
  class AuthorisationController < ApplicationController
    before_action :validate_school
    before_action { @back_url = energy_school_selection_path }
    def show; end

    def update
      redirect_to energy_switch_energy_path(data_exists || create_onboarding_case)
    end

  private

    def data_exists
      Energy::OnboardingCaseOrganisation.find_by(onboardable: @support_organisation)
    end

    def create_onboarding_case
      Energy::CaseCreatable.create_case(current_user, @support_organisation)
    end

    def validate_school
      @support_organisation = Support::Organisation.find_by(urn: params[:id])
      valid_school_urns = current_user.orgs.pluck("urn")

      redirect_to energy_school_selection_path unless @support_organisation && valid_school_urns.include?(params[:id])
    end
  end
end
