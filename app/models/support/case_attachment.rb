# frozen_string_literal: true

module Support
  class CaseAttachment < ApplicationRecord
    belongs_to :case, class_name: "Support::Case", foreign_key: :support_case_id
    belongs_to :email_attachment, class_name: "Support::EmailAttachment", foreign_key: :support_email_attachment_id

    delegate :file, :file_type, to: :email_attachment
    alias_attribute :file_name, :name
  end
end
