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

    trait :with_fixed_category do
      association :category, factory: :support_category, title: "Fixed Category"
    end

    trait :initial do
      state { :initial }
    end

    trait :opened do
      state { :opened }
    end

    trait :resolved do
      state { :resolved }
    end

    trait :closed do
      state { :closed }
    end

    trait :on_hold do
      state { :on_hold }
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

    trait :stage_need do
      association :procurement, factory: %i[support_procurement stage_need]
    end

    trait :stage_market_analysis do
      association :procurement, factory: %i[support_procurement stage_market_analysis]
    end

    trait :stage_sourcing_options do
      association :procurement, factory: %i[support_procurement stage_sourcing_options]
    end

    trait :stage_go_to_market do
      association :procurement, factory: %i[support_procurement stage_go_to_market]
    end

    trait :stage_evaluation do
      association :procurement, factory: %i[support_procurement stage_evaluation]
    end

    trait :stage_contract_award do
      association :procurement, factory: %i[support_procurement stage_contract_award]
    end

    trait :stage_handover do
      association :procurement, factory: %i[support_procurement stage_handover]
    end

    trait :stage_unspecified do
      association :procurement, factory: %i[support_procurement stage_unspecified]
    end
  end
end
