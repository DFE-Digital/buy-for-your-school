FactoryBot.define do
  factory :energy_onboarding_case_organisation, class: 'Energy::OnboardingCaseOrganisation' do
    energy_onboarding_case { nil }
    support_case_organisation { nil }
    what_are_you_switching { "MyString" }
  end
end
