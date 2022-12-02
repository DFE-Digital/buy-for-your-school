class EnergyBill < ApplicationRecord
  belongs_to :request_for_help_form, class_name: "FrameworkRequest", foreign_key: "framework_requests_id"
  belongs_to :support_case, class_name: "Support::Case", foreign_key: "support_cases_id", optional: true

  has_one_attached :file
  enum submission_status: { pending: 0, submitted: 1 }
end
