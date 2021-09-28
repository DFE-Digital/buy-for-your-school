FactoryBot.define do
  factory :support_enquiry, class: "Support::Enquiry" do
    support_request_id { SecureRandom.uuid }
    name { "Bruce Wayne" }
    email { "bruce.wayne.gov.uk" }
    telephone { "0151 000 0000" }
    message { "This is an example request for support - please help!" }

    association :category, factory: :support_category

    trait :with_documents do
      transient do
        document_count { 1 }
      end

      after(:create) do |enquiry, evaluator|
        create_list(:support_document, evaluator.document_count, documentable: enquiry)
        enquiry.reload
      end
    end
  end
end
