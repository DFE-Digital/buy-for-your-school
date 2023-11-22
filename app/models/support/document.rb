# frozen_string_literal: true

module Support
  class Document < ApplicationRecord
    belongs_to :case, class_name: "Support::Case"

    has_one_attached :file

    scope :for_rendering, -> { where.not(document_body: nil) }
  end
end
