FactoryBot.define do
  factory :support_interaction, class: "Support::Interaction" do
    association :agent, factory: :support_agent
    association :case, factory: :support_case
    event_type { 0 }
    body { "This is an example note." }
    additional_data { {} }

    trait :note do
      event_type { 0 }
      body { "This is an example note." }
    end

    trait :phone_call do
      event_type { 1 }
      body { "This is an example phone call." }
    end

    trait :email_from_school do
      event_type { 2 }
      body { "This is an example email from the school." }
    end

    trait :email_to_school do
      event_type { 3 }
      body { "This is an example email to the school." }
    end

    trait :support_request do
      event_type { 4 }
      body { "This is an example support request." }
    end

    trait :hub_note do
      event_type { 5 }
      body { "This is an example hub note." }
    end

    trait :hub_progress_note do
      event_type { 6 }
      body { "This is an example hub progress note." }
    end

    trait :hub_migration do
      event_type { 7 }
      body { "This is an example hub migration." }
    end

    trait :faf_support_request do
      event_type { 8 }
      body { "This is an example framework request." }
    end

    trait :procurement_updated do
      event_type { 9 }
      body { "This is an example procurement detail update." }
    end

    trait :existing_contract_updated do
      event_type { 10 }
      body { "This is an example existing contract update." }
    end

    trait :new_contract_updated do
      event_type { 11 }
      body { "This is an example new contract update." }
    end

    trait :savings_updated do
      event_type { 12 }
      body { "This is an example savings update." }
    end

    trait :state_change do
      event_type { 13 }
      body { "This is an example status update." }
    end

    trait :case_source_changed do
      event_type { 17 }
      body { "This is an example case source update." }
    end
  end
end
