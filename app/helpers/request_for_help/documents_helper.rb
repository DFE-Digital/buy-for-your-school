module RequestForHelp
  module DocumentsHelper
    def available_document_types
      CheckboxOption.from(I18nOption.from("faf.documents.options.%%key%%", FrameworkRequest.document_types), exclusive_fields: %w[none])
    end

    def selected_document_types(document_types, other)
      result = I18nOption.from("faf.documents.options.%%key%%", document_types.excluding("other")).map(&:title)
      result << other if document_types.include?("other")
      result
    end
  end
end
