# frozen_string_literal: true

module Support
  class CaseAttachment < ApplicationRecord
    belongs_to :case, class_name: "Support::Case", foreign_key: :support_case_id
    belongs_to :email_attachment, class_name: "Support::EmailAttachment", foreign_key: :support_email_attachment_id
  end
end
