module Energy
  class AuthorisationController < ApplicationController
    before_action :check_flag
    before_action :validate_school
    before_action { @back_url = energy_switch_energy_path }
    def show; end

    def update
      onboarding_case_creation = Energy::CaseCreatable.create_case(current_user, @support_organisation)
      redirect_to energy_switch_energy_path(onboarding_case_creation)
    end

  private

    def check_flag
      render "errors/not_found", status: :not_found unless Flipper.enabled?(:energy)
    end

    def validate_school
      @support_organisation = Support::Organisation.find_by(urn: params[:id])
      valid_school = current_user.orgs.map { |org| org["urn"] }

      unless @support_organisation && valid_school.include?(params[:id])
        redirect_to energy_school_selection_path
      end
    end
  end
end
