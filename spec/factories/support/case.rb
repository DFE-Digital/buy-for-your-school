FactoryBot.define do
  factory :support_case, class: "Support::Case" do
    ref { "" }
    request_text { "This is an example request for support - please help!" }
    state { 0 }
    support_level { 0 }
    email { "school@email.co.uk" }
    first_name { "School" }
    last_name { "Contact" }

    association :agent, factory: :support_agent

    association :category, factory: :support_category

    association :organisation, factory: :support_organisation

    trait :open do
      state { :open }
    end

    trait :resolved do
      state { :resolved }
    end

    trait :with_documents do
      transient do
        document_count { 1 }
      end

      after(:create) do |kase, evaluator|
        create_list(:support_document, evaluator.document_count, case: kase)
        kase.reload
      end
    end
  end
end
