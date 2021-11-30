FactoryBot.define do
  factory :support_interaction, class: "Support::Interaction" do
    association :agent, factory: :support_agent
    association :case, factory: :support_case
    event_type { 0 }
    body { "This is an example note." }

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
  end
end
