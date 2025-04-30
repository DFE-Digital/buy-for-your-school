FactoryBot.define do
  factory :energy_onboarding_case_organisation, class: "Energy::OnboardingCaseOrganisation" do
    association :onboarding_case, factory: :onboarding_case
    association :onboardable, factory: :support_organisation
    switching_energy_type { 0 }
  end
end
