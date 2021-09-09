FactoryBot.define do
  factory :support_document, class: "Support::Document" do
    file_type { "HTML attachment" }
    document_body { "HTML markup of the specification" }

    transient do
      documentable { nil }
    end

    documentable_id { documentable.id }
    documentable_type { documentable.class.name }
  end
end
