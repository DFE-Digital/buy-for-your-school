module Energy
  class TasksController < ApplicationController
    before_action :organisation_details

    ALLOWED_CLASSES = [
      "Support::Organisation",
      "Support::EstablishmentGroup",
    ].freeze
    def show; end

    def update
      render :show
    end

  private

    def organisation_details
      onboarding_organisation = Energy::OnboardingCaseOrganisation.find_by(energy_onboarding_case_id: params[:id])
      onboardable_class = onboarding_organisation&.onboardable_type

      return render("errors/not_found", status: :not_found) unless onboarding_organisation

      if ALLOWED_CLASSES.include?(onboardable_class)
        @organisation_detail = onboardable_class.safe_constantize.find(onboarding_organisation.onboardable_id)
      end
    end
  end
end
