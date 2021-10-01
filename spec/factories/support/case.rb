FactoryBot.define do
  factory :support_case, class: "Support::Case" do
    ref { "" }
    request_text { "This is an example request for support - please help!" }
    state { 0 }
    support_level { 0 }

    association :enquiry, factory: :support_enquiry
    association :category, factory: :support_category
    association :agent, factory: :support_agent
    sub_category_string { "category subtitle" }

    trait :with_documents do
      transient do
        document_count { 1 }
      end

      after(:create) do |kase, evaluator|
        create_list(:support_document, evaluator.document_count, documentable: kase)
        kase.reload
      end
    end
  end
end
