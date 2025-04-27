module Energy::CaseCreatable
  extend ActiveSupport::Concern

  def self.create_case(current_user, support_organisation)
    ActiveRecord::Base.transaction do
      attrs = {
        first_name: current_user.first_name,
        last_name: current_user.last_name,
        email: current_user.email,
        source: :energy_onboarding,
        organisation: support_organisation,
      }
      kase = Support::CreateCase.new(attrs).call
      Support::CreateInteraction.new(kase.id, "create_case", current_user.id, { body: "Case created", additional_data: {} }).call
      onboarding_case = Energy::OnboardingCase.create!(are_you_authorised: true, support_case: kase)
      Energy::OnboardingCaseOrganisation.create!(energy_onboarding_case_id: onboarding_case.id, onboardable: support_organisation)
    end
  end
end
