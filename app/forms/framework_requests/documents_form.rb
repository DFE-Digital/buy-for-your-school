module FrameworkRequests
  class DocumentsForm < BaseForm
    validates :document_types, presence: true
    validates :document_type_other, presence: true, if: -> { @document_types.include?("other") }

    attr_accessor :document_types, :document_type_other

    def initialize(attributes = {})
      super
      @document_types ||= framework_request.document_types
      @document_type_other ||= framework_request.document_type_other
      @document_types.compact_blank!
    end

    def save!
      @document_type_other = nil unless @document_types.include?("other")
      super
    end
  end
end
