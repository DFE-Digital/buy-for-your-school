FactoryBot.define do
  factory :support_document, class: "Support::Document" do
    file_type { "HTML attachment" }
    document_body { "HTML markup of the specification" }
    association :case, factory: :support_case
  end
end
