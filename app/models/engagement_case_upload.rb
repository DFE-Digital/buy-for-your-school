# frozen_string_literal: true

class EngagementCaseUpload < ApplicationRecord
  has_one_attached :file
  enum :upload_status, { pending: 0, submitted: 1 }

  def name = filename
  def file_name = filename
  def file_size = file.attachment.byte_size
  def file_type = file.attachment.content_type
  def description = "User attached file"
end
