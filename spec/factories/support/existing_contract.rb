FactoryBot.define do
  factory :support_existing_contract, class: "Support::ExistingContract" do
    supplier { "ACME Corp" }
    started_at { "" }
    ended_at { "2021-12-01" }
    duration { "" }
    spend { "9.99" }
    type { "Support::ExistingContract" }
  end
end
