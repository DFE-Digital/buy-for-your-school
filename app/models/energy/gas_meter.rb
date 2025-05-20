class Energy::GasMeter < ApplicationRecord
  belongs_to :onboarding_case_organisation, class_name: "Energy::OnboardingCaseOrganisation",
                                            foreign_key: "energy_onboarding_case_organisation_id"

  MAX_METER_COUNT = 5

  validates :mprn,
            presence: true,
            format: { with: /\A[1-9][0-9]{5,11}\z/ },
            uniqueness: { case_sensitive: false, scope: :energy_onboarding_case_organisation_id, message: :error_unique }
  validates :gas_usage,
            presence: true,
            numericality: { greater_than_or_equal_to: 0, less_than: 1_000_000 }

  validate :maximum_mprn_per_organisation, on: :create

  def maximum_mprn_per_organisation
    if onboarding_case_organisation.gas_meters.count >= MAX_METER_COUNT
      errors.add(:base, :maximum_mprn_per_organisation)
    end
  end
end
