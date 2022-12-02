class EnergyBill < ApplicationRecord
  belongs_to :framework_request, class_name: "FrameworkRequest"
  belongs_to :support_case, class_name: "Support::Case", optional: true

  has_one_attached :file
  enum submission_status: { pending: 0, submitted: 1 }
end
