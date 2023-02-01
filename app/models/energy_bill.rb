class EnergyBill < ApplicationRecord
  belongs_to :framework_request, class_name: "FrameworkRequest"
  belongs_to :support_case, class_name: "Support::Case", optional: true

  has_one_attached :file
  enum submission_status: { pending: 0, submitted: 1 }

  def file_name = filename
  def file_size = file.attachment.byte_size
  def file_type = file.attachment.content_type
end