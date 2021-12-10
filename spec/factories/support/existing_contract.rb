FactoryBot.define do
  factory :support_existing_contract, class: "Support::ExistingContract" do
    # type { "Support::ExistingContract" }
    supplier { "" }
    ended_at { "2021-12-01" }
    spend { "" }
  end
end
