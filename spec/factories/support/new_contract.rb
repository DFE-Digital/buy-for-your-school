FactoryBot.define do
  factory :support_new_contract, class: "Support::NewContract" do
    type { "Support::NewContract" }

    trait :populated do
      supplier { "ACME Corp" }
      started_at { "2020-01-01" }
      ended_at { "2021-01-01" }
      duration { 12.months }
      spend { "9.99" }
    end
  end
end
