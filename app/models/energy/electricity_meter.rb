class Energy::ElectricityMeter < ApplicationRecord
  belongs_to :onboarding_case_organisation, class_name: "Energy::OnboardingCaseOrganisation",
                                            foreign_key: "energy_onboarding_case_organisation_id"

  MAX_METER_COUNT = 5

  validates :mpan,
            presence: true,
            format: { with: /\A\d{13}\z/ }
  validates :is_half_hourly, inclusion: { in: [true, false] }

  validates :supply_capacity,
            presence: true,
            numericality: { greater_than_or_equal_to: 0, less_than: 1_000_000 },
            if: :is_half_hourly?

  validates :data_aggregator,
            :data_collector,
            :meter_operator,
            presence: true,
            format: { with: /\A[a-zA-Z\s]+\z/ },
            if: :is_half_hourly?

  validates :electricity_usage,
            presence: true,
            numericality: { greater_than_or_equal_to: 0, less_than: 1_000_000 }

  validate :maximum_mpan_per_organisation, on: :create

  def maximum_mpan_per_organisation
    if onboarding_case_organisation.electricity_meters.count >= MAX_METER_COUNT
      errors.add(:base, :maximum_mpan_per_organisation)
    end
  end
end
