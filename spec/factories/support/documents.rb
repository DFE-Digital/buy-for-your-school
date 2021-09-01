FactoryBot.define do
  factory :support_document, class: "Support::Document" do
    file_type { "MyString" }
    document_body { "MyString" }
    documentable_type { "MyString" }
    documentable_id { "" }
  end
end
