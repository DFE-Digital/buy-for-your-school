class EnergyBill < ApplicationRecord
  belongs_to :request_for_help_form, class: "FrameworkRequest"
  belongs_to :support_case, class: "Support::Case"

  has_one_attached :file
  enum submission_status: { pending: 0, submitted: 1 }
end
