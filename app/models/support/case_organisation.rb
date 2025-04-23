module Support
  class CaseOrganisation < ApplicationRecord
    belongs_to :case, class_name: "Support::Case", foreign_key: "support_case_id"
    belongs_to :organisation, class_name: "Support::Organisation", foreign_key: "support_organisation_id"
    has_one :energy_onboarding_case_organisation, class_name: "Energy::OnboardingCaseOrganisation", foreign_key: "support_case_organisation_id"
  end
end
