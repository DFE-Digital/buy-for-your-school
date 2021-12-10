FactoryBot.define do
  factory :support_new_contract, class: "Support::NewContract" do
    type { "Support::NewContract" }
    supplier { "" }
    started_at { "2020-10-01" }
    spend { "" }
  end
end