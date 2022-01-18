FactoryBot.define do
  factory :support_existing_contract, class: "Support::ExistingContract" do
    type { "Support::ExistingContract" }

    trait :populated do
      supplier { "ACME Corp" }
      started_at { "2020-01-01" }
      ended_at { "2021-01-01" }
      duration { 12.months }
      spend { "9.99" }
    end
  end
end
