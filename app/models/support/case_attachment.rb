# frozen_string_literal: true

module Support
  class CaseAttachment < ApplicationRecord
    belongs_to :case, class_name: "Support::Case", foreign_key: :support_case_id
    belongs_to :attachable, polymorphic: true, optional: true

    delegate :file, :file_type, to: :attachable

    def file_name = custom_name.presence || attachable.file_name
  end
end
