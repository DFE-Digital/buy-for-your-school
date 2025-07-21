class Energy::GasMeter < ApplicationRecord
  belongs_to :onboarding_case_organisation, class_name: "Energy::OnboardingCaseOrganisation",
                                            foreign_key: "energy_onboarding_case_organisation_id"

  after_save :update_support_case_timestamp
  after_destroy :update_support_case_timestamp

  MAX_METER_COUNT = 5

  validates :mprn,
            presence: true,
            format: { with: Energy::MeterNumberFormat::VALID_METER_NUMBER_REGEX }
  validates :gas_usage,
            presence: true,
            numericality: { greater_than_or_equal_to: 0, less_than: 1_000_000 }

  validate :validate_mprn_format, on: %i[create update]
  validate :maximum_mprn_per_organisation, on: :create
  validate :mprn_uniqueness_with_active_cases, on: %i[create update]

  before_save :sanitize_mprn

  def validate_mprn_format
    digits = mprn.to_s.gsub(/\D/, "")
    if digits.length < 6 || digits.length > 12
      errors.add(:mprn, :invalid)
    end
  end

  def maximum_mprn_per_organisation
    if onboarding_case_organisation.gas_meters.count >= MAX_METER_COUNT
      errors.add(:base, :maximum_mprn_per_organisation)
    end
  end

  def mprn_uniqueness_with_active_cases
    duplicate_data = Energy::GasMeter.where(mprn:).where.not(id:) # Exclude the current record
    active_support_cases = Support::Case
      .where(id: Energy::OnboardingCase
        .where(id: Energy::OnboardingCaseOrganisation
          .where(id: duplicate_data.pluck(:energy_onboarding_case_organisation_id))
          .pluck(:energy_onboarding_case_id))
        .pluck(:support_case_id))
      .where.not(state: %w[closed resolved])

    errors.add(:mprn, :error_unique) if active_support_cases.exists?
  end

private

  def sanitize_mprn
    self.mprn = mprn.gsub(/[\s\-()]/, "") if mprn.present?
  end

  def update_support_case_timestamp
    onboarding_case_organisation&.update_support_case_timestamp
  end
end
