class UsabilitySurveyResponse < ApplicationRecord
  USAGE_REASONS = %w[browsing finding_a_framework guidance request_for_help other].freeze

  enum :service, { find_a_buying_solution: 0 }, prefix: true

  validates :service_helpful, inclusion: { in: [true, false], message: "Select if the service helped you" }, on: :service_helpful
  validates :service_not_helpful_reason, presence: { message: "Tell us why the service was not helpful" }, if: -> { service_helpful == false }
  validates :usage_reason_other, presence: { message: "Tell us what you used the service for" }, if: -> { usage_reasons&.include?("other") }
  validates :service, presence: { message: "Select which service you used" }
  validate :at_least_one_field_present

  before_validation :sanitize_fields

  def at_least_one_field_present
    if [usage_reasons, improvements].all?(&:blank?) && service_helpful.nil?
      errors.add(:base, "At least one field must be filled in")
    end
  end

  def sanitize_fields
    self.usage_reasons = Array(usage_reasons).reject(&:blank?)
  end
end
