class Energy::ElectricityMeter < ApplicationRecord
  include SanitiseMeterNumbers

  belongs_to :onboarding_case_organisation, class_name: "Energy::OnboardingCaseOrganisation",
                                            foreign_key: "energy_onboarding_case_organisation_id"

  after_save :update_support_case_timestamp
  after_destroy :update_support_case_timestamp

  MAX_METER_COUNT = 5

  validates :mpan,
            presence: true,
            format: { with: Energy::MeterNumberFormat::VALID_METER_NUMBER_REGEX }
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

  validate :validate_mpan_format, on: %i[create update]
  validate :maximum_mpan_per_organisation, on: :create
  validate :mpan_uniqueness_with_active_cases, on: %i[create update]

  before_save :sanitize_mpan

  def validate_mpan_format
    digits = mpan.to_s.gsub(/\D/, "")
    if digits.length != 13
      errors.add(:mpan, :invalid)
    end
  end

  def maximum_mpan_per_organisation
    if onboarding_case_organisation.electricity_meters.count >= MAX_METER_COUNT
      errors.add(:base, :maximum_mpan_per_organisation)
    end
  end

  def mpan_uniqueness_with_active_cases
    duplicate_data = Energy::ElectricityMeter.where(mpan:).where.not(id:)
    active_support_cases = Support::Case
      .where(id: Energy::OnboardingCase
        .where(id: Energy::OnboardingCaseOrganisation
          .where(id: duplicate_data.pluck(:energy_onboarding_case_organisation_id))
          .pluck(:energy_onboarding_case_id))
        .pluck(:support_case_id))
      .where.not(state: %w[closed resolved])

    errors.add(:mpan, :error_unique) if active_support_cases.exists?
  end

private

  def sanitize_mpan
    self.mpan = sanitise_meter_number(mpan) if mpan.present?
  end

  def update_support_case_timestamp
    onboarding_case_organisation&.update_support_case_timestamp
  end
end
