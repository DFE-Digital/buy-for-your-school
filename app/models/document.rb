class Document < ApplicationRecord
  belongs_to :framework_request, class_name: "FrameworkRequest"
  belongs_to :support_case, class_name: "Support::Case", optional: true

  has_one_attached :file
  enum submission_status: { pending: 0, submitted: 1 }

  def name = filename
  def file_name = filename
  def file_size = file.attachment.byte_size
  def file_type = file.attachment.content_type
  def description = "User submitted document"

  def submit
    update!(submission_status: :submitted, support_case: framework_request.support_case)

    Support::CaseAttachment.create!(
      attachable: self,
      support_case_id:,
      custom_name: file_name,
      description: "User uploaded document",
      created_at:,
      updated_at:,
    )
  end
end
