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

    association :procurement, factory: :support_procurement

    association :existing_contract, factory: :support_existing_contract

    association :new_contract, factory: :support_new_contract

    trait :initial do
      state { :initial }
    end

    trait :open do
      state { :open }
    end

    trait :resolved do
      state { :resolved }
    end

    trait :closed do
      state { :closed }
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

    trait :action_required do
      action_required { true }
    end
  end
end
