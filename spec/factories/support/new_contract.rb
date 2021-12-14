FactoryBot.define do
  factory :support_new_contract, class: "Support::NewContract" do
    supplier { "ACME Corp" }
    started_at { "2020-12-01" }
    ended_at { "" }
    duration { "" }
    spend { "9.99" }
    type { "Support::NewContract" }
  end
end
