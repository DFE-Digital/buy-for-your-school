FactoryBot.define do
  factory :support_interaction, class: "Support::Interaction" do
    association :agent, factory: :support_agent
    type { 0 }
    body { "This is an example note." }

    trait :note do
      type { 0 }
      body { "This is an example note." }
    end

    trait :phone_call do
      type { 1 }
      body { "This is an example phone call." }
    end

    trait :email_from_school do
      type { 2 }
      body { "This is an example email from the school." }
    end

    trait :email_to_school do
      type { 3 }
      body { "This is an example email to the school." }
    end
  end
end
